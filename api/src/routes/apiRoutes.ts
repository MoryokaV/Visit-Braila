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
import fitnessController from "../controllers/fitnessController";
import madeInBrailaController from "../controllers/madeInBrailaController";
import personalitiesController from "../controllers/personalitiesController";
import { uploadPDF } from "../utils/pdf";

const apiRouter: Router = Router();

const imageStorage = multer.memoryStorage();
const imageUpload = multer({ storage: imageStorage });

const pdfStorage = multer.diskStorage({
  destination: "static/pdf/",
  filename: function (_, file, cb) {
    cb(null, file.originalname);
  },
});
const pdfUpload = multer({ storage: pdfStorage });

apiRouter.get("/serverStorage", async (_, res: Response) =>
  res.status(200).send(await getServerStorage()),
);
apiRouter.post("/uploadImages/:folder", imageUpload.array("files[]"), uploadImages);
apiRouter.post("/uploadPDF", pdfUpload.single("pdfFile"), uploadPDF);

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
apiRouter.use(fitnessController);
apiRouter.use(madeInBrailaController);
apiRouter.use(personalitiesController);

export default apiRouter;
