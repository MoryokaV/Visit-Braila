import { Response, Router, Request } from "express";
import { ObjectId } from "mongodb";
import { deleteImages, getBlurhashString } from "../utils/images";
import { hotelsCollection } from "../db";
import { Hotel } from "../models/hotelModel";
import { requiresAuth } from "../middleware/auth";
import { filterTrendingByItemId } from "../utils/trending";

const router: Router = Router();

router.get("/fetchHotels", async (req: Request, res: Response) => {
  const hotels = await hotelsCollection.find().sort("index", 1).toArray();

  return res.status(200).send(hotels);
});

router.get("/findHotel/:id", async (req: Request, res: Response) => {
  const { id } = req.params;

  if (!ObjectId.isValid(id)) {
    return res.status(404).end();
  }

  const hotel = await hotelsCollection.findOne({ _id: new ObjectId(id) });

  if (hotel == null) {
    return res.status(404).end();
  }

  return res.status(200).send(hotel);
});

router.post("/insertHotel", requiresAuth, async (req: Request, res: Response) => {
  const hotel = req.body as Hotel;
  hotel.primary_image_blurhash = await getBlurhashString(
    hotel.images[hotel.primary_image - 1],
  );
  hotel.index = (await hotelsCollection.find().toArray()).length;

  await hotelsCollection.insertOne(hotel);

  return res.status(200).send("New entry has been inserted");
});

interface UpdateHotelRequestBody {
  images_to_delete: [string];
  _id: string;
  hotel: Hotel;
}

router.put("/editHotel", requiresAuth, async (req: Request, res: Response) => {
  const { images_to_delete, _id, hotel } = req.body as UpdateHotelRequestBody;

  hotel.primary_image_blurhash = await getBlurhashString(
    hotel.images[hotel.primary_image - 1],
  );

  deleteImages(images_to_delete, "hotels");

  await hotelsCollection.updateOne({ _id: new ObjectId(_id) }, { $set: hotel });

  return res.status(200).send("Entry has been updated");
});

router.delete("/deleteHotel/:_id", requiresAuth, async (req: Request, res: Response) => {
  const { _id } = req.params;
  const hotel = await hotelsCollection.findOne({ _id: new ObjectId(_id) });

  const images: Array<string> | undefined = hotel?.images;

  if (images) {
    deleteImages(images, "hotels");
  }

  //remove from trending
  filterTrendingByItemId(_id);

  // reorder
  const items = await hotelsCollection.find().sort("index", 1).toArray();
  await Promise.all(
    items.map(async item => {
      if (item.index > hotel!.index) {
        return hotelsCollection.updateOne(
          { _id: new ObjectId(item._id) },
          { $set: { index: item.index - 1 } },
        );
      }
    }),
  );

  await hotelsCollection.deleteOne({ _id: new ObjectId(_id) });

  return res.status(200).send("Successfully deleted document");
});

export default router;
