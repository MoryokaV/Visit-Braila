#!/usr/bin/env python3

from flask import Flask, render_template, request, redirect
from pymongo import MongoClient
from werkzeug.utils import secure_filename
import os
import json

app = Flask(__name__)

MEDIA_FOLDER = os.path.join(app.root_path, "static/media")
ALLOWED_EXTENSIONS = ["png", "jpg", "jpeg", "webp", "svg"]

client = MongoClient("");
db = client.visitbraila

@app.route("/")
def index():
    return render_template("index.html") 

@app.route("/secondPage", methods=["GET", "POST"])
def secondPage():
    if request.method == "POST" and request.files:
        name = request.form["name"] 
        image = request.files['image']
    
        filename = secure_filename(image.filename)
        path = os.path.join(MEDIA_FOLDER, filename)
        image.save(path)
        
        db.sights.insert_one({"name": name, "imageUrl": "static/media/" + filename})
        
        return redirect("/")

    return render_template("secondPage.html")

@app.route("/fetchSights")
def fetchSights():
    return json.dumps(list(db.sights.find()), default=str)

@app.route("/listSights")
def listSights():
    return render_template("listSights.html")

if __name__ == '__main__':
    app.run(debug=True, port=8080);
