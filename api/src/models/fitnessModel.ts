import { ObjectId } from "mongodb";

export type Fitness = {
  _id?: ObjectId;
  name: string;
  description: string;
  images: Array<string>;
  primary_image: number;
  latitude: number;
  longitude: number;
  external_link: string;
  index: number;
};
