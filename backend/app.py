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

def logged_in(f):
    @wraps(f)
    def checkLoginStatus(*args, **kwargs):
        if session.get("logged_in"):
            return f(*args, **kwargs)
        else:
            return redirect("/login")
    return checkLoginStatus 

@app.route("/login", methods=["POST", "GET"])
def login():
    if request.method == "POST":
        if db.login.find_one()["username"] == request.json["user"] and db.login.find_one()["password"] == hashlib.md5(request.json["pass"].encode('utf-8')).hexdigest():
            session["logged_in"] = True 
            
            return make_response("Logged in", 200)
        else:
            return make_response("Wrong user or password!", 401)
    return render_template("login.html")

@app.route("/admin")
@logged_in
def index():
    return render_template("index.html") 

@app.route("/admin/tags")
@logged_in
def tags():
    return render_template("tags.html")

@app.route("/admin/sights")
@logged_in
def sights():
    return render_template("sights.html")

@app.route("/admin/tours")
@logged_in
def tours():
    return render_template("tours.html")

@app.route("/admin/trending")
@logged_in
def trending():
    return render_template("trending.html")

@app.route("/admin/about")
@logged_in
def about():
    return render_template("about.html")

@app.route("/api/insertSight", methods=["POST"])
def insertSight():
    sight = request.get_json()

    db.sights.insert_one({"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "primary_image": sight['primary_image'], "position": sight['position']})
    
    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchSights")
def fetchSights():
    return json.dumps(list(db.sights.find()), default=str)

@app.route("/api/deleteSight/<_id>", methods=["DELETE"])
def deleteSight(_id):
    # delete local sight images first
    images = json.loads(findSight(_id))['images']
    deleteImages(images)

    db.sights.delete_one({"_id": ObjectId(_id)})
    return make_response("Successfully deleted document", 200)

@app.route("/api/findSight/<_id>")
def findSight(_id):
    sight = db.sights.find_one({"_id": ObjectId(_id)})

    if sight is None:
        return make_response("Invalid sight id", 400)

    return json.dumps(sight, default=str)

@app.route("/api/editSight", methods=["PUT"])
def editSight():
    data = request.get_json()

    deleteImages(data['images_to_delete'])
    sight = data['sight']

    db.sights.update_one({"_id": ObjectId(sight['_id'])}, {"$set": {"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "primary_image": sight['primary_image'], "position": sight['position']}})
    return make_response("Entry has been updated", 200)

@app.route("/api/insertTour", methods=["POST"])
def insertTour():
    tour = request.get_json()
    
    db.tours.insert_one({"name": tour['name'], "stages": tour['stages'], "description": tour['description'], "images": tour['images'], "primary_image": tour['primary_image'], "route": tour['route']})
    return make_response("New entry has been inserted", 200) 

@app.route("/api/fetchTours")
def fetchTours():
    return json.dumps(list(db.tours.find()), default=str)

@app.route("/api/deleteTour/<_id>", methods=["DELETE"])
def deleteTour(_id):
    # delete local tour images first
    images = json.loads(findTour(_id))['images']
    deleteImages(images)

    db.tours.delete_one({"_id": ObjectId(_id)})
    return make_response("Successfully deleted document", 200)

@app.route("/api/findTour/<_id>")
def findTour(_id):
    return json.dumps(db.tours.find_one({"_id": ObjectId(_id)}), default=str)

@app.route("/api/editTour", methods=["PUT"])
def editTour():
    data = request.get_json()

    deleteImages(data['images_to_delete'])
    tour = data['tour'] 

    db.tours.update_one({"_id": ObjectId(tour['_id'])}, {"$set": {"name": tour['name'], "stages": tour['stages'], "description": tour['description'], "images": tour['images'], "primary_image": tour['primary_image'], "route": tour['route']}})
    return make_response("Entry has been updated", 200)

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
            db.sights.update_one({"_id": ObjectId(sight['_id'])}, {"$set": {"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "primary_image": sight['primary_image'], "position": sight['position']}})
         
    db.tags.delete_one({"name": name})

    return make_response("Successfully deleted document", 200)

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

@app.route("/api/fetchAboutParagraphs")
def fetchAboutParagraphs():
    return json.dumps(list(db.about.find()), default=str)

@app.route("/api/updateAboutParagraph", methods=["PUT"])
def updateAboutParagraph():
    updatedContent = request.get_json()
    paragraphs = json.loads(fetchAboutParagraphs())
    _id = None

    for paragraph in paragraphs:
        if paragraph['name'] == updatedContent['name']:
            _id = paragraph['_id']            
            break

    db.about.update_one({"_id": ObjectId(_id)}, {"$set": {"content": updatedContent['content']}})
    return make_response("Entry has been updated", 200)

@app.route("/api/uploadImages/<folder>", methods=["POST"])
def uploadImages(folder):
    for image in request.files.getlist('files[]'):
        path = folder + "/" + image.filename 

        compressed = Image.open(image)        
        
        compressed.save(os.path.join(app.config["MEDIA_FOLDER"], path), optimize=True, quality=65)

    return make_response("Images have been uploaded", 200)

def deleteImages(images):
    for image in images:
        try:
            os.remove(app.root_path + image)
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

if __name__ == '__main__':
    init_dir()
    app.run(debug=True, port=8080)
