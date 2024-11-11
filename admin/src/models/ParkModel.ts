export type Park = {
  _id: string;
  name: string;
  images: Array<string>;
  primary_image: number;
  primary_image_blurhash: string;
  latitude: number;
  longitude: number;
  type: ParkType;
  index: number;
};

export enum ParkType {
  relaxare = "relaxare",
  joaca = "joaca",
  fitness = "fitness",
}
