import { Response, Router, Request } from "express";
import { ObjectId } from "mongodb";
import { toursCollection } from "../db";
import { Tour } from "../models/tourModel";
import { deleteImages } from "../utils/images";
import { requiresAuth } from "../middleware/auth";

const router: Router = Router();

router.get("/fetchTours", async (req: Request, res: Response) => {
  const tours = await toursCollection.find().sort("index", 1).toArray();

  return res.status(200).send(tours);
});

router.get("/findTour/:id", async (req: Request, res: Response) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(404).end();
  }

  const tour = await toursCollection.findOne({ _id: new ObjectId(id) });

  if (tour == null) {
    return res.status(404).end();
  }

  return res.status(200).send(tour);
});

router.post("/insertTour", requiresAuth, async (req: Request, res: Response) => {
  const tour = req.body as Tour;
  tour.index = (await toursCollection.find().toArray()).length;

  await toursCollection.insertOne(tour);

  return res.status(200).send("New entry has been inserted");
});

interface UpdateTourRequestBody {
  images_to_delete: [string];
  _id: string;
  tour: Tour;
}

router.put("/editTour", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, _id, tour } = req.body as UpdateTourRequestBody;

  deleteImages(images_to_delete, "tours");

  await toursCollection.updateOne({ _id: new ObjectId(_id) }, { $set: tour });

  return res.status(200).send("Entry has been updated");
});

router.delete("/deleteTour/:_id", requiresAuth, async (req: Request, res: Response) => {
  const { _id } = req.params;
  const tour = await toursCollection.findOne({ _id: new ObjectId(_id) });

  const images: Array<string> | undefined = tour?.images;

  if (images) {
    deleteImages(images, "tours");
  }

  // reorder
  const items = await toursCollection.find().sort("index", 1).toArray();
  await Promise.all(
    items.map(async item => {
      if (item.index > tour!.index) {
        return toursCollection.updateOne(
          { _id: new ObjectId(item._id) },
          { $set: { index: item.index - 1 } },
        );
      }
    }),
  );

  await toursCollection.deleteOne({ _id: new ObjectId(_id) });

  return res.status(200).send("Successfully deleted document");
});

router.put("/updateTourIndex", requiresAuth, async (req: Request, res: Response) => {
  const { oldIndex, newIndex, items } = req.body as {
    oldIndex: number;
    newIndex: number;
    items: string[];
  };

  let j = 0;

  for (let i = Math.min(oldIndex, newIndex); i <= Math.max(oldIndex, newIndex); i++) {
    toursCollection.updateOne({ _id: new ObjectId(items[j]) }, { $set: { index: i } });
    j += 1;
  }
});

export default router;
