import { Collection, Db, MongoClient } from "mongodb";
import { User } from "./models/userModel";
import { Sight } from "./models/sightModel";
import { Tag } from "./models/tagModel";
import { Tour } from "./models/tourModel";
import { Restaurant } from "./models/restaurantModel";
import { Hotel } from "./models/hotelModel";
import { TrendingItem } from "./models/trendingModel";
import { Event } from "./models/eventModel";
import { About } from "./models/aboutModel";
import { Park } from "./models/parkModel";
import { Fitness } from "./models/fitnessModel";
import { MadeInBraila } from "./models/madeInBrailaModel";
import { Personality } from "./models/personalityModel";

export let db: Db;
export let usersCollection: Collection<User>;
export let tagsCollection: Collection<Tag>;
export let sightsCollection: Collection<Sight>;
export let toursCollection: Collection<Tour>;
export let restaurantsCollection: Collection<Restaurant>;
export let hotelsCollection: Collection<Hotel>;
export let trendingCollection: Collection<TrendingItem>;
export let eventsCollection: Collection<Event>;
export let aboutCollection: Collection<About>;
export let parksCollection: Collection<Park>;
export let fitnessCollection: Collection<Fitness>;
export let madeInBrailaCollection: Collection<MadeInBraila>;
export let personalitiesCollection: Collection<Personality>;

export const connectToDatabase = async (client: MongoClient) => {
  await client
    .connect()
    .then((client: MongoClient) => {
      db = client.db("visitbraila");

      usersCollection = db.collection("login");
      tagsCollection = db.collection("tags");
      sightsCollection = db.collection("sights");
      toursCollection = db.collection("tours");
      restaurantsCollection = db.collection("restaurants");
      hotelsCollection = db.collection("hotels");
      eventsCollection = db.collection("events");
      trendingCollection = db.collection("trending");
      aboutCollection = db.collection("about");
      parksCollection = db.collection("parks");
      fitnessCollection = db.collection("fitness");
      madeInBrailaCollection = db.collection("madeinbraila");
      personalitiesCollection = db.collection("personalities");
    })
    .catch(e => {
      console.log(`[database]: An error occurred while connecting to database: ${e}`);
    });
};
