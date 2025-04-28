import { ObjectId } from "mongodb";

export type Personality = {
  _id?: ObjectId;
  name: string;
  description: string;
  images: Array<string>;
  primary_image: number;
  primary_image_blurhash: string;
  sight_link?: string;
  pdf: string;
  type: PersonalityType;
  index: number;
};

export enum PersonalityType {
  personalitate = "personalitate",
  legenda = "legenda",
}
