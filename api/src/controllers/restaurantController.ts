import { Response, Router, Request } from "express";
import { ObjectId } from "mongodb";
import { restaurantsCollection } from "../db";
import { Restaurant } from "../models/restaurantModel";
import { deleteImages, getBlurhashString } from "../utils/images";
import { requiresAuth } from "../middleware/auth";
import { filterTrendingByItemId } from "../utils/trending";

const router: Router = Router();

router.get("/fetchRestaurants", async (req: Request, res: Response) => {
  const restaurants = await restaurantsCollection.find().sort("index", 1).toArray();

  return res.status(200).send(restaurants);
});

router.get("/findRestaurant/:id", async (req: Request, res: Response) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(404).end();
  }

  const restaurant = await restaurantsCollection.findOne({
    _id: new ObjectId(id),
  });

  if (restaurant == null) {
    return res.status(404).end();
  }

  return res.status(200).send(restaurant);
});

router.post("/insertRestaurant", requiresAuth, async (req: Request, res: Response) => {
  const restaurant = req.body as Restaurant;
  restaurant.primary_image_blurhash = await getBlurhashString(
    restaurant.images[restaurant.primary_image - 1],
  );
  restaurant.index = (await restaurantsCollection.find().toArray()).length;

  await restaurantsCollection.insertOne(restaurant);

  return res.status(200).send("New entry has been inserted");
});

interface UpdateRestaurantRequestBody {
  images_to_delete: [string];
  _id: string;
  restaurant: Restaurant;
}

router.put("/editRestaurant", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, _id, restaurant } = req.body as UpdateRestaurantRequestBody;

  restaurant.primary_image_blurhash = await getBlurhashString(
    restaurant.images[restaurant.primary_image - 1],
  );

  deleteImages(images_to_delete, "restaurants");

  await restaurantsCollection.updateOne({ _id: new ObjectId(_id) }, { $set: restaurant });

  return res.status(200).send("Entry has been updated");
});

router.delete(
  "/deleteRestaurant/:_id",
  requiresAuth,
  async (req: Request, res: Response) => {
    const { _id } = req.params;
    const restaurant = await restaurantsCollection.findOne({ _id: new ObjectId(_id) });

    const images: Array<string> | undefined = restaurant?.images;

    if (images) {
      deleteImages(images, "restaurants");
    }

    //remove from trending
    filterTrendingByItemId(_id);

    // reorder
    const items = await restaurantsCollection.find().sort("index", 1).toArray();
    await Promise.all(
      items.map(async item => {
        if (item.index > restaurant!.index) {
          return restaurantsCollection.updateOne(
            { _id: new ObjectId(item._id) },
            { $set: { index: item.index - 1 } },
          );
        }
      }),
    );

    await restaurantsCollection.deleteOne({ _id: new ObjectId(_id) });

    return res.status(200).send("Successfully deleted document");
  },
);

export default router;
