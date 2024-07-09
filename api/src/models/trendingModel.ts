import { ObjectId } from "mongodb";

export type TrendingItem = {
  _id?: ObjectId;
  item_id: string;
  type: string;
  index: number;
};
