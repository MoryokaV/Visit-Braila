import { ObjectId } from "mongodb";

export type Personality = {
  _id?: ObjectId;
  name: string;
  description: string;
  images: Array<string>;
  primary_image: number;
  primary_image_blurhash: string;
  sight_link?: string;
  index: number;
};
