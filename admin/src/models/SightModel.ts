export type Sight = {
  _id: string;
  name: string;
  tags: Array<string>;
  description: string;
  images: Array<string>;
  primary_image: number;
  latitude: number;
  longitude: number;
  external_link: string;
  primary_image_blurhash: string;
  index: number;
};
