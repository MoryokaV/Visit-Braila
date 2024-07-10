import { Request, Response, Router } from "express";
import { aboutCollection } from "../db";
import { requiresAuth } from "../middleware/auth";
import { deleteImages, getBlurhashString } from "../utils/images";

const router: Router = Router();

router.get("/fetchAboutData", async (_, res: Response) => {
  const aboutData = await aboutCollection.findOne();

  return res.status(200).send(aboutData);
});

router.put("/updateAbout", async (req: Request, res: Response) => {
  const about = req.body;

  await aboutCollection.updateOne({ name: "about" }, { $set: about });

  return res.status(200).send("Entry has been updated");
});

router.put("/updateCoverImage", requiresAuth, async (req: Request, res: Response) => {
  const newImg = req.body as { path: string };
  const newImgBlurhash = await getBlurhashString(newImg.path);

  const about = await aboutCollection.findOne({ name: "about" });

  if (about) {
    deleteImages([about.cover_image], "about");
  }

  await aboutCollection.updateOne(
    { name: "about" },
    { $set: { cover_image: newImg.path, cover_image_blurhash: newImgBlurhash } },
  );

  return res.status(200).send("Entry has been updated");
});

export default router;
