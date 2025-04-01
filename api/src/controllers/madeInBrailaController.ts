import { Response, Router, Request } from "express";
import { ObjectId } from "mongodb";
import { madeInBrailaCollection } from "../db";
import { deleteImages, getBlurhashString } from "../utils/images";
import { requiresAuth } from "../middleware/auth";
import { MadeInBraila } from "../models/madeInBrailaModel";

const router: Router = Router();

router.get("/fetchMadeInBraila", async (_, res: Response) => {
  const madeInBraila = await madeInBrailaCollection.find().sort("index", 1).toArray();

  return res.status(200).send(madeInBraila);
});

router.get("/findMadeInBraila/:id", async (req: Request, res: Response) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(404).end();
  }

  const madeInBraila = await madeInBrailaCollection.findOne({
    _id: new ObjectId(id),
  });

  if (madeInBraila == null) {
    return res.status(404).end();
  }

  return res.status(200).send(madeInBraila);
});

router.post("/insertMadeInBraila", requiresAuth, async (req: Request, res: Response) => {
  const madeInBraila = req.body as MadeInBraila;
  madeInBraila.primary_image_blurhash = await getBlurhashString(
    madeInBraila.images[madeInBraila.primary_image - 1],
  );
  madeInBraila.index = (await madeInBrailaCollection.find().toArray()).length;

  await madeInBrailaCollection.insertOne(madeInBraila);

  return res.status(200).send("New entry has been inserted");
});

interface UpdateMadeInBrailaRequestBody {
  images_to_delete: [string];
  _id: string;
  madeInBraila: MadeInBraila;
}

router.put("/editMadeInBraila", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, _id, madeInBraila } =
    req.body as UpdateMadeInBrailaRequestBody;

  madeInBraila.primary_image_blurhash = await getBlurhashString(
    madeInBraila.images[madeInBraila.primary_image - 1],
  );

  deleteImages(images_to_delete, "madeinbraila");

  await madeInBrailaCollection.updateOne(
    { _id: new ObjectId(_id) },
    { $set: madeInBraila },
  );

  return res.status(200).send("Entry has been updated");
});

router.delete(
  "/deleteMadeInBraila/:_id",
  requiresAuth,
  async (req: Request, res: Response) => {
    const { _id } = req.params;
    const madeInBraila = await madeInBrailaCollection.findOne({ _id: new ObjectId(_id) });

    const images: Array<string> | undefined = madeInBraila?.images;

    if (images) {
      deleteImages(images, "madeinbraila");
    }

    // reorder
    const items = await madeInBrailaCollection.find().sort("index", 1).toArray();
    await Promise.all(
      items.map(async item => {
        if (item.index > madeInBraila!.index) {
          return madeInBrailaCollection.updateOne(
            { _id: new ObjectId(item._id) },
            { $set: { index: item.index - 1 } },
          );
        }
      }),
    );

    await madeInBrailaCollection.deleteOne({ _id: new ObjectId(_id) });

    return res.status(200).send("Successfully deleted document");
  },
);

router.put("/updateMadeInBrailaIndex", requiresAuth, async (req: Request, _) => {
  const { oldIndex, newIndex, items } = req.body as {
    oldIndex: number;
    newIndex: number;
    items: string[];
  };

  let j = 0;

  for (let i = Math.min(oldIndex, newIndex); i <= Math.max(oldIndex, newIndex); i++) {
    madeInBrailaCollection.updateOne(
      { _id: new ObjectId(items[j]) },
      { $set: { index: i } },
    );
    j += 1;
  }
});

export default router;
