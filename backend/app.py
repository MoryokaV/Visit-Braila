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

app = Flask(__name__)
app.config["MEDIA_FOLDER"] = os.path.join(app.root_path, "static/media")

app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

client = MongoClient(os.getenv("MONGO_URL"))
db = client.visitbraila

@app.route("/favicon.ico")
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'favicon.ico')

@app.route("/apple-touch-icon.png")
def apple_touch_icon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'apple-touch-icon.png')
    
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

    if db.login.find_one({"username": username, "password": password}) is not None:
        session['logged_in'] = True 
        session['username'] = username

        if username == "master":
            return make_response(json.dumps({"url": "/master"}), 200)

        return make_response(json.dumps({"url": "/admin"}), 200)
    else:
        return make_response("Wrong user or password!", 401)

@app.route("/logout")
def logout():
    session.clear()
        
    return redirect("/login")

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
def insertUser():
    user = request.get_json()

    db.login.insert_one({"username": user['username'], "password": hashlib.sha256(user['password'].encode("utf-8")).hexdigest()})
    
    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchUsers")
def fetchUsers():
    return json.dumps(list(db.login.find()), default=str)

@app.route("/api/deleteUser/<_id>", methods=["DELETE"])
def deleteUser(_id):
    db.login.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

# --- SIGHTS ---  

@app.route("/api/insertSight", methods=["POST"])
def insertSight():
    sight = request.get_json()

    db.sights.insert_one({"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "primary_image": sight['primary_image'], "latitude": float(sight['latitude']), "longitude": float(sight['longitude']), "external_link": sight['external_link']})
    
    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchSights")
def fetchSights():
    return json.dumps(list(db.sights.find()), default=str)

@app.route("/api/deleteSight/<_id>", methods=["DELETE"])
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
                db.trending.update_one({"_id": ObjectId(item['_id'])}, {"$set": {"sight_id": item['sight_id'], "index": item['index'] - 1}})
              
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
def editSight():
    data = request.get_json()

    deleteImages(data['images_to_delete'], 'sights')
    sight = data['sight']

    db.sights.update_one({"_id": ObjectId(sight['_id'])}, {"$set": {"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "primary_image": sight['primary_image'], "latitude": float(sight['latitude']), "longitude": float(sight['longitude']), "external_link": sight['external_link']}})
    return make_response("Entry has been updated", 200)

# --- TOURS ---  

@app.route("/api/insertTour", methods=["POST"])
def insertTour():
    tour = request.get_json()
    
    db.tours.insert_one({"name": tour['name'], "stages": tour['stages'], "description": tour['description'], "images": tour['images'], "primary_image": tour['primary_image'], "length": float(tour['length']), "external_link": tour['external_link']})
    return make_response("New entry has been inserted", 200) 

@app.route("/api/fetchTours")
def fetchTours():
    return json.dumps(list(db.tours.find()), default=str)

@app.route("/api/deleteTour/<_id>", methods=["DELETE"])
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
def editTour():
    data = request.get_json()

    deleteImages(data['images_to_delete'], 'tours')
    tour = data['tour'] 

    db.tours.update_one({"_id": ObjectId(tour['_id'])}, {"$set": {"name": tour['name'], "stages": tour['stages'], "description": tour['description'], "images": tour['images'], "primary_image": tour['primary_image'], "length": float(tour['length']), "external_link": tour['external_link']}})
    return make_response("Entry has been updated", 200)

# --- EVENTS ---  

@app.route("/api/insertEvent", methods=["POST"])
def insertEvent():
    event = request.get_json()

    date_time = parser.isoparse(event['date_time'])
    end_date_time = None
    expire_at = date_time + relativedelta(days=+1)

    try:
        end_date_time = parser.isoparse(event['end_date_time'])
        expire_at = end_date_time + relativedelta(days =+ 1) 
    except KeyError:
        pass
        
    record = db.events.insert_one({"name": event['name'], "date_time": date_time, "end_date_time": end_date_time, "expire_at": expire_at, "description": event['description'], "images": event['images'], "primary_image": event['primary_image']})
    
    cleanUpEventsImages()

    sendNewEventNotification(event['name'], record.inserted_id)

    return make_response("New entry has been inserted", 200) 

@app.route("/api/fetchEvents")
def fetchEvents():
    return json.dumps(list(db.events.find().sort("date_time", 1)), default=str)

@app.route("/api/deleteEvent/<_id>", methods=["DELETE"])
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

    db.events.update_one({"_id": ObjectId(event['_id'])}, {"$set": {"name": event['name'], "date_time": date_time, "end_date_time": end_date_time,  "expire_at": expire_at, "description": event['description'], "images": event['images'], "primary_image": event['primary_image']}})
    return make_response("Entry has been updated", 200)

# --- TAGS ---

@app.route("/api/fetchTags")
def fetchTags():
    return json.dumps(list(db.tags.find()), default=str)

@app.route("/api/insertTag", methods=["POST"])
def insertTag():
    tag = request.get_json()

    db.tags.insert_one({"name": tag['name']}) 

    return make_response("New entry inserted", 200)

@app.route("/api/deleteTag/<name>", methods=["DELETE"])
def deleteTag(name):
    # Remove this tag from all sights
    sights = json.loads(fetchSights())
     
    for sight in sights:
        if name in sight['tags']:
            sight['tags'].remove(name)
            db.sights.update_one({"_id": ObjectId(sight['_id'])}, {"$set": {"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "primary_image": sight['primary_image'], "latitude": float(sight['latitude']), "longitude": float(sight['longitude']), "external_link": sight['external_link']}})
         
    db.tags.delete_one({"name": name})

    return make_response("Successfully deleted document", 200)

# --- TRENDING --- 

@app.route("/api/insertTrendingItem", methods=["POST"])
def insertTrendingItem():
    item = request.get_json()

    db.trending.insert_one({"sight_id": item['sight_id'], "index": item['index']}) 

    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchTrendingItems")
def fetchTrendingItems():
    return json.dumps(list(db.trending.find().sort("index", 1)), default=str)

@app.route("/api/deleteTrendingItem", methods=["DELETE"])
def deleteTrendingItem():
    _id = request.args.get("_id")
    index = int(request.args.get("index"))

    items = json.loads(fetchTrendingItems())
    
    # Decrease indexes when deleting
    for item in items:
        if item['index'] > index:
            db.trending.update_one({"_id": ObjectId(item['_id'])}, {"$set": {"sight_id": item['sight_id'], "index": item['index'] - 1}})

    db.trending.delete_one({"_id": ObjectId(_id)})

    return make_response("Successfully deleted document", 200)

@app.route("/api/updateTrendingItemIndex", methods=["PUT"])
def updateTrendingItemIndex():
    item = request.get_json()

    db.trending.update_one({"_id": ObjectId(item['_id'])}, {"$set": {"index": item['newIndex']}})
    return make_response("Entry has been updated", 200)

# --- ABOUT DATA ---

@app.route("/api/fetchAboutData")
def fetchAboutData():
    return json.dumps(db.about.find_one(), default=str);

@app.route("/api/updateAboutParagraphs", methods=["PUT"])
def updateAboutParagraphs():
    updatedContent = request.get_json()

    db.about.update_one({"name": "about"}, {"$set": {"paragraph1": updatedContent['paragraph1'], "paragraph2": updatedContent['paragraph2']}})
    return make_response("Entry has been updated", 200)

@app.route("/api/updateContactDetails", methods=["PUT"])
def updateContactDetails():
    details = request.get_json()

    db.about.update_one({"name": "about"}, {"$set": {"director": details['director'], "phone": details['phone'], "email": details['email']}})
    return make_response("Entry has been updated", 200)

@app.route("/api/updateCoverImage", methods=["PUT"])
def updateCoverImage():
    item = request.get_json()

    about = db.about.find_one()
    deleteImages([about['cover_image']], "about")

    db.about.update_one({"name": "about"}, {"$set": {"cover_image": item['cover_image']}})
    return make_response("Entry has been updated", 200)

# --- IMAGES ---

@app.route("/api/uploadImages/<folder>", methods=["POST"])
def uploadImages(folder):
    for image in request.files.getlist('files[]'):
        path = folder + "/" + image.filename 

        compressed = Image.open(image)        
        
        compressed.convert("RGB").save(os.path.join(app.config["MEDIA_FOLDER"], path), format="JPEG", optimize=True, quality=60)

    return make_response("Images have been uploaded", 200)

def deleteImages(images, collection):
    for image in images:
        occurrences = 1
        
        if collection == 'sights':
            occurrences = len(list(db.sights.find({"images": image})))
        elif collection == 'tours':
            occurrences = len(list(db.tours.find({"images": image})))
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
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/events"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/events")
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/about"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/about")

if __name__ == '__main__':
    init_dir()
    app.run(debug=True)
