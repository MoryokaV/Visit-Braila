#!/usr/bin/env python3

from flask import Flask, render_template, request, redirect, session, make_response
from flask_session import Session
from functools import wraps
from pymongo import MongoClient
from werkzeug.utils import secure_filename
from bson.objectid import ObjectId
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
            return make_response("Wrong user or password", 401)
    return render_template("login.html")

@app.route("/admin")
@logged_in
def index():
    return render_template("index.html") 

@app.route("/admin/insertSight", methods=["GET", "POST"])
@logged_in
def insertSight():
    if request.method == "POST":
        name = request.form["name"] 
        tags = [] 
        description = request.form["description"]

        paths = []
        for image in request.files.getlist('image'):
            filename = secure_filename(image.filename)
            
            path = "sights/" + filename
            paths.append(path)
            
            image.save(os.path.join(app.config["MEDIA_FOLDER"], path))
        
        position = request.form["position"]

        db.sights.insert_one({"name": name, "tags": tags, "description": description, "images": paths, "position": position})

        return redirect("/admin")

    return render_template("old/insertSight.html")

@app.route("/api/fetchSights")
def fetchSights():
    return json.dumps(list(db.sights.find()), default=str)

@app.route("/api/deleteSight/<_id>", methods=["DELETE"])
def deleteSight(_id):
    #delete local sight images
    images = json.loads(findSight(_id))['images']
    for image in images:
        os.remove(os.path.join(app.config["MEDIA_FOLDER"], image))

    db.sights.delete_one({"_id": ObjectId(_id)})
    return "Successfully deleted document"

@app.route("/api/findSight/<_id>")
def findSight(_id):
    return json.dumps(db.sights.find_one({"_id": ObjectId(_id)}), default=str)

@app.route("/api/updateSight/<_id>", methods=["PUT"])
def updateSight(_id):
    sight = request.get_json()

    db.sights.update_one({"_id": ObjectId(_id)}, {"$set": {"name": sight['name'], "tags": sight['tags'], "description": sight['description'], "images": sight['images'], "position": sight['position']}})
    return make_response("Entry has been updated", 200)

@app.route("/api/uploadImages/<folder>", methods=["POST"])
def uploadImage(folder):
    for image in request.files.getlist('files[]'):
        filename = image.filename

        path = folder + "/" + filename
        
        image.save(os.path.join(app.config["MEDIA_FOLDER"], path))

    return make_response("Images have been uploaded!", 200)

@app.route("/api/deleteImages/<folder>", methods=["DELETE"])
def deleteImage(folder):
    images = request.get_json()['images']

    for image in images:
        path = folder + "/" + image
        os.remove(os.path.join(app.config['MEDIA_FOLDER'], path))

    return make_response("Images have been deleted!", 200)

def init_dir():
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/sights"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/sights")
    if not os.path.exists(app.config["MEDIA_FOLDER"] + "/tours"):
        os.makedirs(app.config["MEDIA_FOLDER"] + "/tours")

if __name__ == '__main__':
    init_dir()
    app.run(debug=True, port=8080);
