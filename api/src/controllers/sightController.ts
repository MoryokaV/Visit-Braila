import { Response, Router, Request } from "express";
import { ObjectId } from "mongodb";
import { sightsCollection } from "../db";
import { Sight } from "../models/sightModel";
import { deleteImages, getBlurhashString } from "../utils/images";
import { requiresAuth } from "../middleware/auth";
import { filterTrendingByItemId } from "../utils/trending";

const router: Router = Router();

router.get("/fetchSights", async (_, res: Response) => {
  const sights = await sightsCollection.find().sort("index", 1).toArray();

  return res.status(200).send(sights);
});

router.get("/findSight/:id", async (req: Request, res: Response) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(404).end();
  }

  const sight = await sightsCollection.findOne({ _id: new ObjectId(id) });

  if (sight == null) {
    return res.status(404).end();
  }

  return res.status(200).send(sight);
});

router.post("/insertSight", requiresAuth, async (req: Request, res: Response) => {
  const sight = req.body as Sight;
  sight.primary_image_blurhash = await getBlurhashString(
    sight.images[sight.primary_image - 1],
  );
  sight.index = (await sightsCollection.find().toArray()).length;

  await sightsCollection.insertOne(sight);

  return res.status(200).send("New entry has been inserted");
});

interface UpdateSightRequestBody {
  images_to_delete: [string];
  _id: string;
  sight: Sight;
}

router.put("/editSight", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, _id, sight } = req.body as UpdateSightRequestBody;

  sight.primary_image_blurhash = await getBlurhashString(
    sight.images[sight.primary_image - 1],
  );

  deleteImages(images_to_delete, "sights");

  await sightsCollection.updateOne({ _id: new ObjectId(_id) }, { $set: sight });

  return res.status(200).send("Entry has been updated");
});

router.delete("/deleteSight/:_id", requiresAuth, async (req: Request, res: Response) => {
  const { _id } = req.params;
  const sight = await sightsCollection.findOne({ _id: new ObjectId(_id) });

  const images: Array<string> | undefined = sight?.images;

  if (images) {
    deleteImages(images, "sights");
  }

  // remove from trending
  filterTrendingByItemId(_id);

  // reorder
  const items = await sightsCollection.find().sort("index", 1).toArray();
  await Promise.all(
    items.map(async item => {
      if (item.index > sight!.index) {
        return sightsCollection.updateOne(
          { _id: new ObjectId(item._id) },
          { $set: { index: item.index - 1 } },
        );
      }
    }),
  );

  await sightsCollection.deleteOne({ _id: new ObjectId(_id) });

  return res.status(200).send("Successfully deleted document");
});

router.put("/updateSightIndex", requiresAuth, async (req: Request, res: Response) => {
  const { oldIndex, newIndex, items } = req.body as {
    oldIndex: number;
    newIndex: number;
    items: string[];
  };

  let j = 0;

  for (let i = Math.min(oldIndex, newIndex); i <= Math.max(oldIndex, newIndex); i++) {
    sightsCollection.updateOne({ _id: new ObjectId(items[j]) }, { $set: { index: i } });
    j += 1;
  }
});

export default router;
