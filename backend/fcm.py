#!/usr/bin/env python3

from pymongo import MongoClient
from firebase_admin import credentials
from firebase_admin import messaging
import firebase_admin
from datetime import * 
import os

# connect to mongodb 
client = MongoClient(os.getenv("MONGO_URL"))
db = client.visitbraila

# authorize firebase project use
cred = credentials.Certificate(os.getenv("VB_FIREBASE_CREDENTIALS")) 
firebase_app = firebase_admin.initialize_app(cred)

def sendDailyNotification():
    events = list(db.events.find().sort("date_time", 1))
    tomorrow_events = 0
        
    for event in events:
        today = datetime.now().date()
        diff = event['date_time'].date() - today

        
        if diff.days == 1:
            tomorrow_events += 1
        elif diff.days > 1:
            break

    if tomorrow_events == 0:
        return

    title = "Mâine în orașul tău"
    body = ""

    if tomorrow_events == 1:
        body = "Un eveniment nou"
    elif tomorrow_events == 2:
        body = "Două evenimente noi"
    elif tomorrow_events < 20:
        body = str(tomorrow_events) + " evenimente noi"
    else:
        body = str(tomorrow_events) + " de evenimente noi" 
    
    message = messaging.Message(
        notification = messaging.Notification(
            title=title,
            body=body,
        ),
        data = {
            'type': 'tomorrow_events',
        },
        android = messaging.AndroidConfig(
            ttl = timedelta(days=2),
        ),
        apns = messaging.APNSConfig(
            headers = {
                "apns-expiration": "172800",
            }
        ),
        topic = "events",
    )

    messaging.send(message)

def sendNewEventNotification(name, _id):
    message = messaging.Message(
        notification = messaging.Notification(
            title="Un nou eveniment in Brăila!",
            body=name,
        ),
        data = {
            'type': 'event',
            'id': str(_id),
        },
        topic = "events",
    )

    messaging.send(message)

if __name__ == '__main__':
    sendDailyNotification()
