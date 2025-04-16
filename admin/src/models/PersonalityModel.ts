export type Personality = {
  _id: string;
  name: string;
  description: string;
  images: Array<string>;
  primary_image: number;
  primary_image_blurhash: string;
  sight_link?: string;
  pdf: string;
  index: number;
};
