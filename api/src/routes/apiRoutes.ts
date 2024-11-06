import { Router, Response } from "express";
import { getServerStorage } from "../utils/storage";
import { uploadImages } from "../utils/images";
import multer from "multer";
import sightController from "../controllers/sightController";
import tagController from "../controllers/tagController";
import tourController from "../controllers/tourController";
import restaurantController from "../controllers/restaurantController";
import hotelController from "../controllers/hotelController";
import eventController from "../controllers/eventController";
import trendingController from "../controllers/trendingController";
import aboutController from "../controllers/aboutController";
import userController from "../controllers/userController";
import parkController from "../controllers/parkController";

const apiRouter: Router = Router();

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

apiRouter.get("/serverStorage", async (_, res: Response) =>
  res.status(200).send(await getServerStorage()),
);
apiRouter.post("/uploadImages/:folder", upload.array("files[]"), uploadImages);

apiRouter.use(sightController);
apiRouter.use(tagController);
apiRouter.use(tourController);
apiRouter.use(restaurantController);
apiRouter.use(hotelController);
apiRouter.use(eventController);
apiRouter.use(trendingController);
apiRouter.use(aboutController);
apiRouter.use(userController);
apiRouter.use(parkController);

export default apiRouter;
