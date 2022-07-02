#!/usr/bin/env python3

from flask import Flask, render_template, request, redirect, send_from_directory, flash
from pymongo import MongoClient
from werkzeug.utils import secure_filename
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
def secondPage():
    if request.method == "POST":
        name = request.form["name"] 
        
        #handle images input
        paths = []
        for image in request.files.getlist('image'):
            filename = secure_filename(image.filename)
            
            path = "sights/" + filename
            paths.append(path)
            
            image.save(os.path.join(app.config["MEDIA_FOLDER"], path))
        
        db.sights.insert_one({"name": name, "images": paths})

        return redirect("/admin")

    return render_template("insertSight.html")

@app.route("/api/fetchSights")
def fetchSights():
    return json.dumps(list(db.sights.find()), default=str)

@app.route("/admin/listSights")
def listSights():
    return render_template("listSights.html")

if __name__ == '__main__':
    app.run(debug=True, port=8080);
