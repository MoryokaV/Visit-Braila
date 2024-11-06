import { ObjectId } from "mongodb";

export type Park = {
  _id?: ObjectId;
  name: string;
  images: Array<string>;
  primary_image: number;
  primary_image_blurhash: string;
  latitude: number;
  longitude: number;
  external_link: string;
  index: number;
};
