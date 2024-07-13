export type Tour = {
  _id: string;
  name: string;
  stages: Array<Stage>;
  description: string;
  images: Array<string>;
  primary_image: number;
  length: number;
  external_link: string;
  index: number;
};

export type Stage = {
  text: string;
  sight_link: string;
};
