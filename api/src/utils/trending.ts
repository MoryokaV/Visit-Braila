import { trendingCollection } from "../db";
import { ObjectId } from "mongodb";

export const filterTrendingByItemId = async (_id: string) => {
  // delete corresponding trending item
  // decrement bigger indexes

  const trending = await trendingCollection.find().toArray();
  const item = await trendingCollection.findOne({ item_id: _id });

  if (item) {
    await Promise.all(
      trending.map(async t_item => {
        if (t_item.index > item.index) {
          return trendingCollection.updateOne(
            { _id: new ObjectId(t_item._id) },
            { $set: { index: t_item.index - 1 } },
          );
        }
      }),
    );

    await trendingCollection.deleteOne({ _id: item._id });
  }
};
