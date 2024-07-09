import { Router, Request, Response } from "express";
import { eventsCollection } from "../db";
import { ObjectId } from "mongodb";
import { requiresAuth } from "../middleware/auth";
import { deleteImages, getBlurhashString } from "../utils/images";
import { Event } from "../models/eventModel";
import dayjs from "dayjs";
import { cleanUpEventsImages } from "../utils/storage";
import { sendNewEventNotification } from "../utils/fcm";
import { filterTrendingByItemId } from "../utils/trending";

const router: Router = Router();

router.get("/fetchEvents", async (req: Request, res: Response) => {
  const events = await eventsCollection.find().toArray();

  return res.status(200).send(events);
});

router.get("/findEvent/:id", async (req: Request, res: Response) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(404).end();
  }

  const event = await eventsCollection.findOne({ _id: new ObjectId(id) });

  if (event == null) {
    return res.status(404).end();
  }

  return res.status(200).send(event);
});

interface InsertEventRequestBody {
  notify: boolean;
  event: Event;
}

router.post("/insertEvent", requiresAuth, async (req: Request, res: Response) => {
  const { notify, event } = req.body as InsertEventRequestBody;

  event.date_time = new Date(event.date_time);
  event.expire_at = dayjs(event.date_time).add(1, "day").toDate();

  if (event.end_date_time) {
    event.end_date_time = new Date(event.end_date_time);
    event.expire_at = dayjs(event.end_date_time).add(1, "day").toDate();
  } else {
    event.end_date_time = null;
  }

  event.primary_image_blurhash = await getBlurhashString(
    event.images[event.primary_image - 1],
  );

  const record = await eventsCollection.insertOne(event);

  cleanUpEventsImages();

  if (notify === true) {
    sendNewEventNotification(event.name, record.insertedId.toString());
  }

  return res.status(200).send("New entry has been inserted");
});

interface UpdateEventRequestBody {
  images_to_delete: [string];
  _id: string;
  event: Event;
}

router.put("/editEvent", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, _id, event } = req.body as UpdateEventRequestBody;

  event.date_time = new Date(event.date_time);
  event.expire_at = dayjs(event.date_time).add(1, "day").toDate();

  if (event.end_date_time) {
    event.end_date_time = new Date(event.end_date_time);
    event.expire_at = dayjs(event.end_date_time).add(1, "day").toDate();
  } else {
    event.end_date_time = null;
  }

  event.primary_image_blurhash = await getBlurhashString(
    event.images[event.primary_image - 1],
  );

  deleteImages(images_to_delete, "events");

  await eventsCollection.updateOne({ _id: new ObjectId(_id) }, { $set: event });

  return res.status(200).send("Entry has been updated");
});

router.delete("/deleteEvent/:_id", requiresAuth, async (req: Request, res: Response) => {
  const { _id } = req.params;

  const images: Array<string> | undefined = (
    await eventsCollection.findOne({ _id: new ObjectId(_id) })
  )?.images;

  if (images) {
    deleteImages(images, "events");
  }

  //remove from trending
  filterTrendingByItemId(_id);

  await eventsCollection.deleteOne({ _id: new ObjectId(_id) });

  return res.status(200).send("Successfully deleted document");
});

export default router;
