#!/usr/bin/env python3

from flask import Flask, render_template, request, redirect, session, make_response, send_from_directory
from flask_session import Session
from functools import wraps
from pymongo import MongoClient
from bson.objectid import ObjectId
from shutil import disk_usage
from PIL import Image
import os
import json
import hashlib
from dateutil import parser
from dateutil.relativedelta import relativedelta
from fcm import sendNewEventNotification
import blurhash

app = Flask(__name__)
app.config["MEDIA_FOLDER"] = os.path.join(app.root_path, "static/media")

app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

client = MongoClient(os.getenv("MONGO_URL"))
db = client.visitbraila

# --- ICONS --- 

@app.route("/favicon.ico")
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'favicon.ico')

@app.route("/apple-touch-icon.png")
def apple_touch_icon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'apple-touch-icon.png')

# --- LOGIN --- 
    
@app.route("/")
def root():
    return redirect("/admin")

def master_login_required(f):
    @wraps(f)
    def checkForMasterUser(*args, **kwargs):
        if session['username'] == "master":
            return f(*args, **kwargs) 
        else:
            return redirect("/login")

    return checkForMasterUser

def login_required(f):
    @wraps(f)
    def checkLoginStatus(*args, **kwargs):
        if session.get("logged_in"):
            return f(*args, **kwargs)
        else:
            return redirect("/login")

    return checkLoginStatus 

@app.route("/login", methods=["POST", "GET"])
def login():
    if request.method == "GET":
        return render_template("login.html")

    username = request.json['user']
    password = hashlib.sha256(request.json["pass"].encode('utf-8')).hexdigest()

    user = db.login.find_one({"username": username, "password": password}) 

    if user is not None:
        session['logged_in'] = True 
        session['username'] = username
        session['fullname'] = user['fullname']

        if username == "master":
            return make_response(json.dumps({"url": "/master"}), 200)

        return make_response(json.dumps({"url": "/admin"}), 200)
    else:
        return make_response("Wrong user or password!", 401)

@app.route("/logout")
def logout():
    session.clear()
        
    return redirect("/login")

@app.route("/api/currentName")
def getCurrentUserFullname():
    return make_response(json.dumps({"fullname": session['fullname']}), 200)    

# --- CMS ROUTES --- 

@app.route("/master")
@login_required
@master_login_required
def master():
    return render_template("master.html")

@app.route("/admin")
@login_required
def index():
    return render_template("index.html") 

@app.route("/admin/tags")
@login_required
def tags():
    return render_template("tags.html")

@app.route("/admin/sights")
@login_required
def sights():
    return render_template("sights.html")

@app.route("/admin/tours")
@login_required
def tours():
    return render_template("tours.html")

@app.route("/admin/restaurants")
@login_required
def restarants():
    return render_template("restaurants.html")

@app.route("/admin/hotels")
@login_required
def hotels():
    return render_template("hotels.html")

@app.route("/admin/events")
@login_required
def events():
    return render_template("events.html")

@app.route("/admin/trending")
@login_required
def trending():
    return render_template("trending.html")

@app.route("/admin/about")
@login_required
def about():
    return render_template("about.html")

# --- USERS --- 

@app.route("/api/insertUser", methods=["POST"])
@login_required
def insertUser():
    user = request.get_json()

    db.login.insert_one({"fullname": user['fullname'], "username": user['username'], "password": hashlib.sha256(user['password'].encode("utf-8")).hexdigest()})
    
    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchUsers")
def fetchUsers():
    return json.dumps(list(db.login.find()), default=str)

@app.route("/api/deleteUser/<_id>", methods=["DELETE"])
@login_required
def deleteUser(_id):
    db.login.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

@app.route("/api/editMasterPassword", methods=["PUT"])
@login_required
@master_login_required
def editMasterPassword():
    data = request.get_json()

    db.login.update_one({"username": "master"}, {"$set": {"password": hashlib.sha256(data['new_password'].encode('utf-8')).hexdigest()}})

    return make_response("Entry has been updated", 200)

# --- SIGHTS ---  

@app.route("/api/insertSight", methods=["POST"])
@login_required
def insertSight():
    sight = request.get_json()

    sight['latitude'] = float(sight['latitude'])
    sight['longitude'] = float(sight['longitude'])
    sight['primary_image_blurhash'] = getBlurhash(sight['images'][sight['primary_image'] - 1])

    db.sights.insert_one(sight)
    
    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchSights")
def fetchSights():
    return json.dumps(list(db.sights.find()), default=str)

@app.route("/api/deleteSight/<_id>", methods=["DELETE"])
@login_required
def deleteSight(_id):
    # delete local sight images first
    images = json.loads(findSight(_id))['images']
    deleteImages(images, 'sights')

    # delete corresponding trending item
    trending = json.loads(fetchTrendingItems())
    trending_item_id = ""
    trending_item_index = 0

    for item in trending:
        if _id in item['sight_id']:    
            trending_item_id = item['_id']
            trending_item_index = item['index']
            break
    
    if trending_item_id != "":
        for item in trending:
            if item['index'] > trending_item_index:
                db.trending.update_one({"_id": ObjectId(item['_id'])}, {"$set": {"index": item['index'] - 1}})
              
        db.trending.delete_one({"_id": ObjectId(trending_item_id)})

    # delete sight
    db.sights.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

@app.route("/api/findSight/<_id>")
def findSight(_id):
    sight = db.sights.find_one({"_id": ObjectId(_id)})

    if sight is None:
        return make_response("Invalid sight id", 404)

    return json.dumps(sight, default=str)

@app.route("/api/editSight", methods=["PUT"])
@login_required
def editSight():
    data = request.get_json()

    deleteImages(data['images_to_delete'], 'sights')

    sight = data['sight']
    sight['latitude'] = float(sight['latitude'])
    sight['longitude'] = float(sight['longitude'])
    sight['primary_image_blurhash'] = getBlurhash(sight['images'][sight['primary_image'] - 1])

    db.sights.update_one({"_id": ObjectId(data['_id'])}, {"$set": sight})

    return make_response("Entry has been updated", 200)

# --- TOURS ---  

@app.route("/api/insertTour", methods=["POST"])
@login_required
def insertTour():
    tour = request.get_json()

    tour['length'] = float(tour['length'])
    
    db.tours.insert_one(tour)

    return make_response("New entry has been inserted", 200) 

@app.route("/api/fetchTours")
def fetchTours():
    return json.dumps(list(db.tours.find()), default=str)

@app.route("/api/deleteTour/<_id>", methods=["DELETE"])
@login_required
def deleteTour(_id):
    # delete local tour images first
    images = json.loads(findTour(_id))['images']
    deleteImages(images, 'tours')

    db.tours.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

@app.route("/api/findTour/<_id>")
def findTour(_id):
    tour = db.tours.find_one({"_id": ObjectId(_id)})

    if tour is None:
        return make_response("Invalid tour id", 404)

    return json.dumps(tour, default=str)

@app.route("/api/editTour", methods=["PUT"])
@login_required
def editTour():
    data = request.get_json()

    deleteImages(data['images_to_delete'], 'tours')

    tour = data['tour'] 
    tour['length'] = float(tour['length'])

    db.tours.update_one({"_id": ObjectId(data['_id'])}, {"$set": tour})

    return make_response("Entry has been updated", 200)

# --- RESTAURANTS ---  

@app.route("/api/insertRestaurant", methods=["POST"])
@login_required
def insertRestaurant():
    restaurant = request.get_json()

    restaurant['latitude'] = float(restaurant['latitude'])
    restaurant['longitude'] = float(restaurant['longitude'])
    restaurant['primary_image_blurhash'] = getBlurhash(restaurant['images'][restaurant['primary_image'] - 1])

    db.restaurants.insert_one(restaurant)
    
    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchRestaurants")
def fetchRestaurants():
    return json.dumps(list(db.restaurants.find()), default=str)

@app.route("/api/deleteRestaurant/<_id>", methods=["DELETE"])
@login_required
def deleteRestaurant(_id):
    # delete local restaurant images first
    images = json.loads(findRestaurant(_id))['images']
    deleteImages(images, 'restaurants')

    # delete restaurant
    db.restaurants.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

@app.route("/api/findRestaurant/<_id>")
def findRestaurant(_id):
    restaurant = db.restaurants.find_one({"_id": ObjectId(_id)})

    if restaurant is None:
        return make_response("Invalid restaurant id", 404)

    return json.dumps(restaurant, default=str)

@app.route("/api/editRestaurant", methods=["PUT"])
@login_required
def editRestaurant():
    data = request.get_json()

    deleteImages(data['images_to_delete'], 'restaurants')

    restaurant = data['restaurant']
    restaurant['latitude'] = float(restaurant['latitude'])
    restaurant['longitude'] = float(restaurant['longitude'])
    restaurant['primary_image_blurhash'] = getBlurhash(restaurant['images'][restaurant['primary_image'] - 1])

    db.restaurants.update_one({"_id": ObjectId(data['_id'])}, {"$set": restaurant})

    return make_response("Entry has been updated", 200)

# --- HOTELS ---  

@app.route("/api/insertHotel", methods=["POST"])
@login_required
def insertHotel():
    hotel = request.get_json()

    hotel['latitude'] = float(hotel['latitude'])
    hotel['longitude'] = float(hotel['longitude'])
    hotel['primary_image_blurhash'] = getBlurhash(hotel['images'][hotel['primary_image'] - 1])

    db.hotels.insert_one(hotel)
    
    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchHotels")
def fetchHotels():
    return json.dumps(list(db.hotels.find()), default=str)

@app.route("/api/deleteHotel/<_id>", methods=["DELETE"])
@login_required
def deleteHotel(_id):
    # delete local hotel images first
    images = json.loads(findHotel(_id))['images']
    deleteImages(images, 'hotels')

    # delete hotel
    db.hotels.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

@app.route("/api/findHotel/<_id>")
def findHotel(_id):
    hotel = db.hotels.find_one({"_id": ObjectId(_id)})

    if hotel is None:
        return make_response("Invalid hotel id", 404)

    return json.dumps(hotel, default=str)

@app.route("/api/editHotel", methods=["PUT"])
@login_required
def editHotel():
    data = request.get_json()

    deleteImages(data['images_to_delete'], 'hotels')

    hotel = data['hotel']
    hotel['latitude'] = float(hotel['latitude'])
    hotel['longitude'] = float(hotel['longitude'])
    hotel['primary_image_blurhash'] = getBlurhash(hotel['images'][hotel['primary_image'] - 1])

    db.hotels.update_one({"_id": ObjectId(data['_id'])}, {"$set": hotel})

    return make_response("Entry has been updated", 200)

# --- EVENTS ---  

@app.route("/api/insertEvent", methods=["POST"])
@login_required
def insertEvent():
    data = request.get_json()

    event = data['event']

    date_time = parser.isoparse(event['date_time'])
    end_date_time = None
    expire_at = date_time + relativedelta(days=+1)

    try:
        end_date_time = parser.isoparse(event['end_date_time'])
        expire_at = end_date_time + relativedelta(days =+ 1) 
    except KeyError:
        pass

    event['date_time'] = date_time
    event['end_date_time'] = end_date_time
    event['expire_at'] = expire_at
    event['primary_image_blurhash'] = getBlurhash(event['images'][event['primary_image'] - 1])
        
    record = db.events.insert_one(event)
    
    cleanUpEventsImages()
    
    if data['notify'] == True:
        sendNewEventNotification(event['name'], record.inserted_id)

    return make_response("New entry has been inserted", 200) 

@app.route("/api/fetchEvents")
def fetchEvents():
    return json.dumps(list(db.events.find().sort("date_time", 1)), default=str)

@app.route("/api/deleteEvent/<_id>", methods=["DELETE"])
@login_required
def deleteEvent(_id):
    # delete local event images first
    images = json.loads(findEvent(_id))['images']
    deleteImages(images, 'events')

    db.events.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

@app.route("/api/findEvent/<_id>")
def findEvent(_id):
    event = db.events.find_one({"_id": ObjectId(_id)})

    if event is None:
        return make_response("Invalid tour id", 404)

    return json.dumps(event, default=str)

@app.route("/api/editEvent", methods=["PUT"])
@login_required
def editEvent():
    data = request.get_json()
    
    deleteImages(data['images_to_delete'], 'events')

    event = data['event'] 

    date_time = parser.isoparse(event['date_time'])
    end_date_time = None
    expire_at = date_time + relativedelta(days=+1)

    try:
        end_date_time = parser.isoparse(event['end_date_time'])
        expire_at = end_date_time + relativedelta(days =+ 1) 
    except KeyError:
        pass

    event['date_time'] = date_time
    event['end_date_time'] = end_date_time
    event['expire_at'] = expire_at
    event['primary_image_blurhash'] = getBlurhash(event['images'][event['primary_image'] - 1])

    db.events.update_one({"_id": ObjectId(data['_id'])}, {"$set": event})

    return make_response("Entry has been updated", 200)

# --- TAGS ---

@app.route("/api/fetchTags/<used_for>")
def fetchTags(used_for):
    if used_for == "all":
        return json.dumps(list(db.tags.find()), default=str)

    return json.dumps(list(db.tags.find({"used_for": used_for})), default=str)

@app.route("/api/insertTag", methods=["POST"])
@login_required
def insertTag():
    tag = request.get_json()

    db.tags.insert_one(tag) 

    return make_response("New entry inserted", 200)

@app.route("/api/deleteTag/<name>", methods=["DELETE"])
@login_required
def deleteTag(name):
    tags = json.loads(fetchTags("all"))

    # Remove this tag from all occurrences 
    used_for = ""
    for tag in tags:
        if tag['name'] == name:
            used_for = tag['used_for']
            break

    if used_for == "sights":
        sights = json.loads(fetchSights())
         
        for sight in sights:
            if name in sight['tags']:
                sight['tags'].remove(name)
                db.sights.update_one({"_id": ObjectId(sight['_id'])}, {"$set": {"tags": sight['tags']}})
    elif used_for == "restaurants":
        restaurants = json.loads(fetchRestaurants())
         
        for restaurant in restaurants:
            if name in restaurant['tags']:
                restaurant['tags'].remove(name)
                db.restaurants.update_one({"_id": ObjectId(restaurant['_id'])}, {"$set": {"tags": restaurant['tags']}})
    else:
        hotels = json.loads(fetchHotels())
         
        for hotel in hotels:
            if name in hotel['tags']:
                hotel['tags'].remove(name)
                db.hotels.update_one({"_id": ObjectId(hotel['_id'])}, {"$set": {"tags": hotel['tags']}})
         
    db.tags.delete_one({"name": name})

    return make_response("Successfully deleted document", 200)

# --- TRENDING --- 

@app.route("/api/insertTrendingItem", methods=["POST"])
@login_required
def insertTrendingItem():
    item = request.get_json()

    db.trending.insert_one(item) 

    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchTrendingItems")
def fetchTrendingItems():
    return json.dumps(list(db.trending.find().sort("index", 1)), default=str)

@app.route("/api/deleteTrendingItem", methods=["DELETE"])
@login_required
def deleteTrendingItem():
    _id = request.args.get("_id")
    index = int(request.args.get("index"))

    items = json.loads(fetchTrendingItems())
    
    # Decrease indexes when deleting
    for item in items:
        if item['index'] > index:
            db.trending.update_one({"_id": ObjectId(item['_id'])}, {"$set": {"index": item['index'] - 1}})

    db.trending.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

@app.route("/api/updateTrendingItemIndex", methods=["PUT"])
@login_required
def updateTrendingItemIndex():
    item = request.get_json()

    db.trending.update_one({"_id": ObjectId(item['_id'])}, {"$set": {"index": item['newIndex']}})

    return make_response("Entry has been updated", 200)

# --- ABOUT DATA ---

@app.route("/api/fetchAboutData")
def fetchAboutData():
    return json.dumps(db.about.find_one(), default=str);

@app.route("/api/updateAboutParagraphs", methods=["PUT"])
@login_required
def updateAboutParagraphs():
    updatedContent = request.get_json()

    db.about.update_one({"name": "about"}, {"$set": updatedContent})

    return make_response("Entry has been updated", 200)

@app.route("/api/updateContactDetails", methods=["PUT"])
@login_required
def updateContactDetails():
    details = request.get_json()

    db.about.update_one({"name": "about"}, {"$set": details})

    return make_response("Entry has been updated", 200)

@app.route("/api/updateCoverImage", methods=["PUT"])
@login_required
def updateCoverImage():
    new_img = request.get_json()
    about = db.about.find_one()

    deleteImages([about['cover_image']], "about")

    db.about.update_one({"name": "about"}, {"$set": new_img})
    db.about.update_one({"name": "about"}, {"$set": {"cover_image_blurhash": getBlurhash(new_img['cover_image'])}})

    return make_response("Entry has been updated", 200)

# --- IMAGES ---

def resizeImage(image):
    MEDIUM = 1500
    LARGE = 2100

    w, h = image.size

    if w >= h:
        coef = 0
        breakpoint = MEDIUM;

        if w > LARGE:
            coef = w / LARGE
            breakpoint = LARGE
        elif w > MEDIUM:
            coef = w / MEDIUM
            breakpoint = MEDIUM

        if coef != 0:
            return image.resize((breakpoint, int(h / coef)), Image.Resampling.LANCZOS)
    elif w < h:
        coef = 0
        breakpoint = MEDIUM;

        if h > LARGE:
            coef = h / LARGE
            breakpoint = LARGE;
        elif h > MEDIUM:
            coef = h / MEDIUM
            breakpoint = MEDIUM;

        if coef != 0:
            return image.resize((int(w / coef), breakpoint), Image.Resampling.LANCZOS)

    return image

@app.route("/api/uploadImages/<folder>", methods=["POST"])
@login_required
def uploadImages(folder):
    for image in request.files.getlist('files[]'):
        path = folder + "/" + image.filename 

        compressed = Image.open(image)        
        
        compressed = compressed.convert("RGB")
        compressed = resizeImage(compressed)
        compressed.save(os.path.join(app.config["MEDIA_FOLDER"], path), format="JPEG", optimize=True, quality=60)

    return make_response("Images have been uploaded", 200)

def deleteImages(images, collection):
    for image in images:
        occurrences = 1
        
        if collection == 'sights':
            occurrences = len(list(db.sights.find({"images": image})))
        elif collection == 'tours':
            occurrences = len(list(db.tours.find({"images": image})))
        elif collection == 'restaurants':
            occurrences = len(list(db.restaurants.find({"images": image})))
        elif collection == 'hotels':
            occurrences = len(list(db.hotels.find({"images": image})))
        elif collection == 'events':
            occurrences = len(list(db.events.find({"images": image})))

        if occurrences == 1:
            try:
                os.remove(app.root_path + image)
            except:
                pass

def cleanUpEventsImages():
    # Because of MongoDB TTL index images don't get deleted automatically
    # so i will delete them on the next insert

    folder = "/static/media/events/"
    path = os.path.join(app.config["MEDIA_FOLDER"], "events")
    images = os.listdir(path)

    for image in images:
        occurrences = len(list(db.events.find({"images": folder + image})))

        if occurrences == 0:
            try:
                os.remove(os.path.join(path, image))
            except:
                pass

def getBlurhash(image):
    path = app.root_path + image 
    blur = blurhash.encode(path, x_components=4, y_components=3)
    
    return blur

@app.route("/api/serverStorage")
def serverStorage():
    ssd = disk_usage("/")

    return json.dumps({
        "total": round(ssd.total / (2**30), 1), 
        "used": round(ssd.used / (2**30), 1)
    })

def init_dir():
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/sights"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/sights")
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/tours"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/tours")
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/restaurants"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/restaurants")
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/hotels"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/hotels")
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/events"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/events")
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/about"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/about")

if __name__ == '__main__':
    init_dir()
    app.run(debug=True)
