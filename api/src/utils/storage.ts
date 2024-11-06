import disk from "diskusage";
import os from "os";
import fs from "fs";
import path from "path";
import { eventsCollection } from "../db";

type ServerStorageInfo = {
  total: number;
  used: number;
};

const rootServerPath = os.platform() === "win32" ? "c:" : "/";

export const getServerStorage = async () => {
  try {
    const { total, free } = await disk.check(rootServerPath);

    return <ServerStorageInfo>{
      total: Math.round((total / Math.pow(1024, 3)) * 10) / 10,
      used: Math.round(((total - free) / Math.pow(1024, 3)) * 10) / 10,
    };
  } catch (err) {
    console.error(err);

    return <ServerStorageInfo>{
      total: 0,
      used: 0,
    };
  }
};

export const initMediaDirs = () => {
  const mediaPath = path.join(__dirname, "..", "..", "static", "media");

  try {
    fs.mkdirSync(path.join(mediaPath, "sights"));
    fs.mkdirSync(path.join(mediaPath, "tours"));
    fs.mkdirSync(path.join(mediaPath, "restaurants"));
    fs.mkdirSync(path.join(mediaPath, "hotels"));
    fs.mkdirSync(path.join(mediaPath, "events"));
    fs.mkdirSync(path.join(mediaPath, "about"));
    fs.mkdirSync(path.join(mediaPath, "parks"));
  } catch (_) {
    //pass
  }
};

export const cleanUpEventsImages = () => {
  // Because of MongoDB TTL index images don't get deleted automatically
  // so i will delete them on the next insert

  const folder = `/static/media/events/`;
  const fullPath = path.join(__dirname, "..", "..", folder);

  const files = fs.readdirSync(fullPath);

  files.forEach(async file => {
    const occurrences = await eventsCollection.find({ images: folder + file }).toArray();

    if (occurrences.length === 0) {
      try {
        fs.unlinkSync(path.join(fullPath, file));
      } catch (_) {
        //pass
      }
    }
  });
};
