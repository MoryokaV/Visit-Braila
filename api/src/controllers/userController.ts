import { Request, Response, Router } from "express";
import { usersCollection } from "../db";
import { requiresAdminAuth } from "../middleware/auth";
import { User } from "../models/userModel";
import { createHash } from "crypto";
import { ObjectId } from "mongodb";

const router: Router = Router();

router.get("/fetchUsers", requiresAdminAuth, async (req: Request, res: Response) => {
  const users = await usersCollection.find().toArray();

  return res.status(200).send(users);
});

router.post("/insertUser", requiresAdminAuth, async (req: Request, res: Response) => {
  const user = req.body as User;
  user.password = createHash("sha256").update(user.password).digest("hex");

  await usersCollection.insertOne(user);

  return res.status(200).send("New entry has been inserted");
});

router.put(
  "/editUserPassword/:_id",
  requiresAdminAuth,
  async (req: Request, res: Response) => {
    const { _id } = req.params;
    const { new_password } = req.body;

    await usersCollection.updateOne(
      { _id: new ObjectId(_id) },
      { $set: { password: createHash("sha256").update(new_password).digest("hex") } },
    );

    return res.status(200).send("Entry has been updated");
  },
);

router.delete(
  "/deleteUser/:_id",
  requiresAdminAuth,
  async (req: Request, res: Response) => {
    const { _id } = req.params;

    await usersCollection.deleteOne({ _id: new ObjectId(_id) });

    return res.status(200).send("Successfully deleted document");
  },
);

export default router;
