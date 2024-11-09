import { Response, Router, Request } from "express";
import { ObjectId } from "mongodb";
import { fitnessCollection } from "../db";
import { Fitness } from "../models/fitnessModel";
import { deleteImages } from "../utils/images";
import { requiresAuth } from "../middleware/auth";

const router: Router = Router();

router.get("/fetchFitness", async (_, res: Response) => {
  const fitness = await fitnessCollection.find().sort("index", 1).toArray();

  return res.status(200).send(fitness);
});

router.get("/findFitness/:id", async (req: Request, res: Response) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(404).end();
  }

  const fitness = await fitnessCollection.findOne({ _id: new ObjectId(id) });

  if (fitness == null) {
    return res.status(404).end();
  }

  return res.status(200).send(fitness);
});

router.post("/insertFitness", requiresAuth, async (req: Request, res: Response) => {
  const fitness = req.body as Fitness;
  fitness.index = (await fitnessCollection.find().toArray()).length;

  await fitnessCollection.insertOne(fitness);

  return res.status(200).send("New entry has been inserted");
});

interface UpdateFitnessRequestBody {
  images_to_delete: [string];
  _id: string;
  fitness: Fitness;
}

router.put("/editFitness", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, _id, fitness } = req.body as UpdateFitnessRequestBody;

  deleteImages(images_to_delete, "fitness");

  await fitnessCollection.updateOne({ _id: new ObjectId(_id) }, { $set: fitness });

  return res.status(200).send("Entry has been updated");
});

router.delete(
  "/deleteFitness/:_id",
  requiresAuth,
  async (req: Request, res: Response) => {
    const { _id } = req.params;
    const fitness = await fitnessCollection.findOne({ _id: new ObjectId(_id) });

    const images: Array<string> | undefined = fitness?.images;

    if (images) {
      deleteImages(images, "fitness");
    }

    // reorder
    const items = await fitnessCollection.find().sort("index", 1).toArray();
    await Promise.all(
      items.map(async item => {
        if (item.index > fitness!.index) {
          return fitnessCollection.updateOne(
            { _id: new ObjectId(item._id) },
            { $set: { index: item.index - 1 } },
          );
        }
      }),
    );

    await fitnessCollection.deleteOne({ _id: new ObjectId(_id) });

    return res.status(200).send("Successfully deleted document");
  },
);

router.put("/updateFitnessIndex", requiresAuth, async (req: Request, _) => {
  const { oldIndex, newIndex, items } = req.body as {
    oldIndex: number;
    newIndex: number;
    items: string[];
  };

  let j = 0;

  for (let i = Math.min(oldIndex, newIndex); i <= Math.max(oldIndex, newIndex); i++) {
    fitnessCollection.updateOne({ _id: new ObjectId(items[j]) }, { $set: { index: i } });
    j += 1;
  }
});

export default router;
