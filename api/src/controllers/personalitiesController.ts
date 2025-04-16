import { requiresAuth } from "../middleware/auth";
import { Personality } from "../models/personalityModel";
import { ObjectId } from "mongodb";
import { Response, Router, Request } from "express";
import { personalitiesCollection } from "../db";
import { deleteImages, getBlurhashString } from "../utils/images";
import { deletePDF } from "../utils/pdf";

const router: Router = Router();

router.get("/fetchPersonalities", async (_, res: Response) => {
  const personalities = await personalitiesCollection.find().sort("index", 1).toArray();

  return res.status(200).send(personalities);
});

router.get("/findPersonality/:id", async (req: Request, res: Response) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(404).end();
  }

  const personality = await personalitiesCollection.findOne({ _id: new ObjectId(id) });

  if (personality == null) {
    return res.status(404).end();
  }

  return res.status(200).send(personality);
});

router.post("/insertPersonality", requiresAuth, async (req: Request, res: Response) => {
  const personality = req.body as Personality;
  personality.primary_image_blurhash = await getBlurhashString(
    personality.images[personality.primary_image - 1],
  );
  personality.index = (await personalitiesCollection.find().toArray()).length;

  await personalitiesCollection.insertOne(personality);

  return res.status(200).send("New entry has been inserted");
});

interface UpdatePersonalityRequestBody {
  images_to_delete: [string];
  pdf_to_delete?: string;
  _id: string;
  personality: Personality;
}

router.put("/editPersonality", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, pdf_to_delete, _id, personality } =
    req.body as UpdatePersonalityRequestBody;

  personality.primary_image_blurhash = await getBlurhashString(
    personality.images[personality.primary_image - 1],
  );

  if (pdf_to_delete != null) {
    deletePDF(pdf_to_delete);
  }

  deleteImages(images_to_delete, "personalities");

  await personalitiesCollection.updateOne(
    { _id: new ObjectId(_id) },
    { $set: personality },
  );

  return res.status(200).send("Entry has been updated");
});

router.delete(
  "/deletePersonality/:_id",
  requiresAuth,
  async (req: Request, res: Response) => {
    const { _id } = req.params;
    const personality = await personalitiesCollection.findOne({ _id: new ObjectId(_id) });

    const images: Array<string> | undefined = personality?.images;

    if (images) {
      deleteImages(images, "personalities");
    }

    deletePDF(personality!.pdf);

    // reorder
    const items = await personalitiesCollection.find().sort("index", 1).toArray();
    await Promise.all(
      items.map(async item => {
        if (item.index > personality!.index) {
          return personalitiesCollection.updateOne(
            { _id: new ObjectId(item._id) },
            { $set: { index: item.index - 1 } },
          );
        }
      }),
    );

    await personalitiesCollection.deleteOne({ _id: new ObjectId(_id) });

    return res.status(200).send("Successfully deleted document");
  },
);

router.put("/updatePersonalitiesIndex", requiresAuth, async (req: Request, _) => {
  const { oldIndex, newIndex, items } = req.body as {
    oldIndex: number;
    newIndex: number;
    items: string[];
  };

  let j = 0;

  for (let i = Math.min(oldIndex, newIndex); i <= Math.max(oldIndex, newIndex); i++) {
    personalitiesCollection.updateOne(
      { _id: new ObjectId(items[j]) },
      { $set: { index: i } },
    );
    j += 1;
  }
});

export default router;
