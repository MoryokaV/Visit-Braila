import { ObjectId } from "mongodb";

export type Event = {
  _id?: ObjectId;
  name: string;
  date_time: Date;
  images: Array<string>;
  primary_image: number;
  description: string;
  end_date_time: Date | null;
  expire_at: Date;
  primary_image_blurhash: string;
};
