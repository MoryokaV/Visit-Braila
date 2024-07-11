export const getFilename = (path: string) => path.substring(path.lastIndexOf("/") + 1);

export function getBase64(image: File): Promise<string> {
  const reader = new FileReader();

  return new Promise(resolve => {
    reader.onload = e => {
      resolve(e.target!.result as string);
    };

    reader.readAsDataURL(image);
  });
}

export const createImagesFormData = (formData: FormData, images: File[]) => {
  Array.from(images).forEach(file => {
    formData.append("files[]", file);
  });
};

export const getImagesToDelete = (
  oldImages: Array<string>,
  currentImages: Array<string>,
): Array<string> => {
  const images_to_delete: Array<string> = [];

  oldImages.map(image => {
    if (currentImages.includes(image) === false) {
      images_to_delete.push(image);
    }
  });

  return images_to_delete;
};
