export type Hotel = {
  _id: string;
  name: string;
  stars: number;
  phone: string;
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
