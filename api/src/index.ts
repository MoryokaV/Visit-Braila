import express, { Express, Response } from "express";
import session from "express-session";
import MongoStore from "connect-mongo";
import { MongoClient } from "mongodb";
import dotenv from "dotenv";
import morgan from "morgan";
import cors from "cors";
import apiRouter from "./routes/apiRoutes";
import loginRouter from "./routes/loginRoutes";
import { connectToDatabase } from "./db";
import { appInstallRedirect } from "./utils/installRedirect";
import * as ServerStorage from "./utils/storage";
import path from "path";

dotenv.config();

const app: Express = express();

const PORT = process.env.PORT || 3000;
const MONGO_URL = process.env.VB_MONGODB_URL || "";
const SESSION_SECRET = process.env.SESSION_SECRET || "";
const NODE_ENV = process.env.NODE_ENV || "development";

const client: MongoClient = new MongoClient(MONGO_URL);

const sessionConfig = {
  secret: SESSION_SECRET,
  store: MongoStore.create({
    client: client, //re-use the existing client
    dbName: "visitbraila",
    touchAfter: 24 * 3600, //refresh only after a day
    crypto: {
      secret: "squirrel", //encrypt the content
    },
  }),
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: false,
  },
};

if (NODE_ENV === "production") {
  app.set("trust proxy", 1);
  sessionConfig.cookie.secure = true;
}

app.use(session(sessionConfig));

app.use(morgan("dev"));
app.use(express.json());
app.use(cors());

app.use("/static", express.static(path.join(__dirname, "..", "/static")));

app.use("/api", apiRouter);
app.use("/api", loginRouter);

app.get("/", (_, res: Response) => res.redirect("/admin"));

app.get("/install", appInstallRedirect);

connectToDatabase(client).then(() => {
  ServerStorage.initMediaDirs();

  app.listen(PORT, () => {
    console.log(`[server]: Server is running at http://localhost:${PORT}`);
  });
});
