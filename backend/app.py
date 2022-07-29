#!/usr/bin/env python3

from flask import Flask, render_template, request, redirect, session, make_response
from flask_session import Session
from functools import wraps
from pymongo import MongoClient
from werkzeug.utils import secure_filename
from bson.objectid import ObjectId
from shutil import disk_usage
import os
import json
import hashlib

app = Flask(__name__)
app.config["MEDIA_FOLDER"] = os.path.join(app.root_path, "static/media")

app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

client = MongoClient(os.getenv("MONGO_URL"));
db = client.visitbraila

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

@app.route("/api/insertSight", methods=["POST"])
@logged_in
def insertSight():
    sight = request.get_json()

    db.sights.insert_one({"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "primary_image": sight['primary_image'], "position": sight['position']})
    
    return make_response("New entry has been inserted", 200)

@app.route("/api/fetchSights")
def fetchSights():
    return json.dumps(list(db.sights.find()), default=str)

@app.route("/api/deleteSight/<_id>", methods=["DELETE"])
def deleteSight(_id):
    #delete local sight images first
    images = json.loads(findSight(_id))['images']
    for image in images:
        os.remove(os.path.join(app.config["MEDIA_FOLDER"], image))

    db.sights.delete_one({"_id": ObjectId(_id)})
    return make_response("Successfully deleted document", 200)

@app.route("/api/findSight/<_id>")
def findSight(_id):
    return json.dumps(db.sights.find_one({"_id": ObjectId(_id)}), default=str)

@app.route("/api/editSight", methods=["PUT"])
def editSight():
    sight = request.get_json()

    db.sights.update_one({"_id": ObjectId(sight['_id'])}, {"$set": {"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "primary_image": sight['primary_image'], "position": sight['position']}})
    return make_response("Entry has been updated", 200)

@app.route("/api/fetchTours")
def fetchTours():
    return json.dumps(list(db.tours.find()), default=str)

@app.route("/api/deleteTour/<_id>", methods=["DELETE"])
def deleteTour(_id):
    #delete local tour images first
    images = json.loads(findTour(_id))['images']
    for image in images:
        os.remove(os.path.join(app.config["MEDIA_FOLDER"], image))

    db.tours.delete_one({"_id": ObjectId(_id)})
    return make_response("Successfully deleted document", 200)

@app.route("/api/findTour/<_id>")
def findTour(_id):
    return json.dumps(db.tours.find_one({"_id": ObjectId(_id)}), default=str)

@app.route("/api/editTour", methods=["PUT"])
def editTour():
    tour = request.get_json()

    db.tours.update_one({"_id": ObjectId(tour['_id'])}, {"$set": {"name": tour['name'], "stages": tour['stages'], "description": tour['description'], "images": tour['images'], "primary_image": tour['primary_image'], "route": tour['route']}})
    return make_response("Entry has been updated", 200)

@app.route("/api/fetchTags")
def fetchTags():
    return json.dumps(list(db.tags.find()), default=str)

@app.route("/api/insertTag", methods=["POST"])
def insertTag():
    tag = request.get_json();

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

@app.route("/api/uploadImages/<folder>", methods=["POST"])
def uploadImage(folder):
    for image in request.files.getlist('files[]'):
        filename = image.filename

        path = folder + "/" + filename
        
        image.save(os.path.join(app.config["MEDIA_FOLDER"], path))

    return make_response("Images have been uploaded", 200)

@app.route("/api/deleteImages/<folder>", methods=["DELETE"])
def deleteImage(folder):
    images = request.get_json()['images']

    for image in images:
        path = folder + "/" + image
        os.remove(os.path.join(app.config['MEDIA_FOLDER'], path))

    return make_response("Images have been deleted", 200)

@app.route("/api/serverStorage")
def serverStorage():
    ssd = disk_usage("/")

    return json.dumps({"total": round(ssd.total / (2**30), 1), "used": round(ssd.used / (2**30), 1)})

def init_dir():
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/sights"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/sights")
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/tours"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/tours")

if __name__ == '__main__':
    init_dir()
    app.run(debug=True, port=8080);
