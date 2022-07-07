#!/usr/bin/env python3

from flask import Flask, render_template, request, redirect
from pymongo import MongoClient
from werkzeug.utils import secure_filename
from bson.objectid import ObjectId
import os
import json

app = Flask(__name__)
app.config["MEDIA_FOLDER"] = os.path.join(app.root_path, "static/media")

client = MongoClient("");
db = client.visitbraila

@app.route("/admin")
def index():
    return render_template("index.html") 

@app.route("/admin/insertSight", methods=["GET", "POST"])
def insertSight():
    if request.method == "POST":
        name = request.form["name"] 
        category = request.form["category"]
        description = request.form["description"]

        paths = []
        for image in request.files.getlist('image'):
            filename = secure_filename(image.filename)
            
            path = "sights/" + filename
            paths.append(path)
            
            image.save(os.path.join(app.config["MEDIA_FOLDER"], path))
        
        position = request.form["position"]

        db.sights.insert_one({"name": name, "category": category, "description": description, "images": paths, "position": position})

        return redirect("/admin")

    return render_template("old/insertSight.html")

@app.route("/api/fetchSights")
def fetchSights():
    return json.dumps(list(db.sights.find()), default=str)

@app.route("/api/deleteSight/<_id>", methods=["DELETE"])
def deleteSight(_id):
    db.sights.delete_one({"_id": ObjectId(_id)})
    return "Successfully deleted document"

@app.route("/api/findSight/<_id>")
def findSight(_id):
    return json.dumps(db.sights.find_one({"_id": ObjectId(_id)}), default=str)

@app.route("/api/updateSight/<_id>", methods=["PUT"])
def updateSight(_id):
    db.sights.update_one({"_id": ObjectId(_id)}, {"$set": {"name": name, "category": category, "description": description, "images": paths, "position": position}})
    return "Successfully updated document"

if __name__ == '__main__':
    app.run(debug=True, port=8080);
