import { ObjectId } from "mongodb";

export type Tour = {
  _id?: ObjectId;
  name: string;
  stages: Array<Stage>;
  description: string;
  images: Array<string>;
  primary_image: number;
  length: number;
  external_link: string;
  index: number;
};

type Stage = {
  text: string;
  sight_link: string;
};
