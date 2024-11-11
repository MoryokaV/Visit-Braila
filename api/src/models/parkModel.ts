import { ObjectId } from "mongodb";

export type Park = {
  _id?: ObjectId;
  name: string;
  images: Array<string>;
  primary_image: number;
  primary_image_blurhash: string;
  latitude: number;
  longitude: number;
  type: ParkType;
  index: number;
};

enum ParkType {
  relaxare = "relaxare",
  joaca = "joaca",
  fitness = "fitness",
}
