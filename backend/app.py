#!/usr/bin/env python3

from flask import Flask, render_template, request, redirect
from pymongo import MongoClient
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)

MEDIA_FOLDER = os.path.join(app.root_path, "media")
ALLOWED_EXTENSIONS = ["png", "jpg", "jpeg", "webp", "svg"]

@app.route("/")
def index():
    return render_template("index.html") 

@app.route("/secondPage", methods=["GET", "POST"])
def secondPage():
    if request.method == "POST":
        if request.files:
            image = request.files['image']
            filename = secure_filename(image.filename)

            image.save(os.path.join(MEDIA_FOLDER, filename))

            return redirect("/")

    return render_template("secondPage.html")

if __name__ == '__main__':
    #client = MongoClient("mongodb://admin:visitbraila@193.22.95.33:27017/?authMechanism=DEFAULT");
    #print(client.list_database_names())
    #db = client.visitbraila
    #sights = db.sights
    #sights.insert_one({"name": "Teatru"})

    app.run(debug=True, port=8000);
