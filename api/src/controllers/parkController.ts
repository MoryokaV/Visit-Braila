import { Response, Router, Request } from "express";
import { ObjectId } from "mongodb";
import { parksCollection } from "../db";
import { Park } from "../models/parkModel";
import { deleteImages, getBlurhashString } from "../utils/images";
import { requiresAuth } from "../middleware/auth";

const router: Router = Router();

router.get("/fetchParks", async (_, res: Response) => {
  const parks = await parksCollection.find().sort("index", 1).toArray();

  return res.status(200).send(parks);
});

router.post("/insertParks", requiresAuth, async (req: Request, res: Response) => {
  const park = req.body as Park;
  park.primary_image_blurhash = await getBlurhashString(
    park.images[park.primary_image - 1],
  );
  park.index = (await parksCollection.find().toArray()).length;

  await parksCollection.insertOne(park);

  return res.status(200).send("New entry has been inserted");
});

interface UpdateParkRequestBody {
  images_to_delete: [string];
  _id: string;
  park: Park;
}

router.put("/editPark", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, _id, park } = req.body as UpdateParkRequestBody;

  park.primary_image_blurhash = await getBlurhashString(
    park.images[park.primary_image - 1],
  );

  deleteImages(images_to_delete, "parks");

  await parksCollection.updateOne({ _id: new ObjectId(_id) }, { $set: park });

  return res.status(200).send("Entry has been updated");
});

router.delete("/deletePark/:_id", requiresAuth, async (req: Request, res: Response) => {
  const { _id } = req.params;
  const park = await parksCollection.findOne({ _id: new ObjectId(_id) });

  const images: Array<string> | undefined = park?.images;

  if (images) {
    deleteImages(images, "parks");
  }

  // reorder
  const items = await parksCollection.find().sort("index", 1).toArray();
  await Promise.all(
    items.map(async item => {
      if (item.index > park!.index) {
        return parksCollection.updateOne(
          { _id: new ObjectId(item._id) },
          { $set: { index: item.index - 1 } },
        );
      }
    }),
  );

  await parksCollection.deleteOne({ _id: new ObjectId(_id) });

  return res.status(200).send("Successfully deleted document");
});

router.put("/updateParkIndex", requiresAuth, async (req: Request, _) => {
  const { oldIndex, newIndex, items } = req.body as {
    oldIndex: number;
    newIndex: number;
    items: string[];
  };

  let j = 0;

  for (let i = Math.min(oldIndex, newIndex); i <= Math.max(oldIndex, newIndex); i++) {
    parksCollection.updateOne({ _id: new ObjectId(items[j]) }, { $set: { index: i } });
    j += 1;
  }
});

export default router;
