import { useEffect } from "react";
import { UseFormRegister, UseFormSetValue } from "react-hook-form";
import { IoCloseOutline, IoCloudUploadOutline, IoImageOutline } from "react-icons/io5";
import { getFilename } from "../../../utils/images";

interface Props {
  register: UseFormRegister<any>;
  setValue: UseFormSetValue<any>;
  images?: Array<string>;
  files: File[];
  collection: string;
}

export const ImagesField: React.FC<Props> = ({
  register,
  setValue,
  images = [],
  files = [],
  collection,
}) => {
  useEffect(() => {
    register("images");
    setValue("images", images);

    register("files");
    setValue("files", files);
  }, []);

  const addImage = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newFiles = Array.from(e.target.files!).filter(file => {
      if (images.includes(`/static/media/${collection}/${file.name}`)) {
        alert(`'${file.name}' is already present in list!`);
        return false;
      }

      return true;
    });

    files.push(...newFiles);

    newFiles.map(newFile => {
      images.push(`/static/media/${collection}/${newFile.name}`);
    });

    setValue("files", files);
    setValue("images", images);

    e.target.value = "";
  };

  const removeImage = (image: string) => {
    const filename = getFilename(image);

    setValue(
      "files",
      Array.from(files).filter(file => file.name !== filename),
    );

    images.splice(images.indexOf(image), 1);
    setValue("images", images);
  };

  return (
    <section className="col-12 d-flex gap-3">
      <label htmlFor="images" style={{ cursor: "pointer" }}>
        Images
        <input
          type="file"
          className="hidden-input"
          id="images"
          accept="image/*"
          multiple
          required={images.length === 0}
          onChange={addImage}
        />
      </label>
      <ul className="img-container">
        {images.map((image, index) => {
          let uploaded = true;
          files.map(file => {
            if (file.name === getFilename(image)) {
              uploaded = false;
              return;
            }
          });

          return (
            <li key={index} className="highlight-onhover">
              <a
                href={uploaded ? image : undefined}
                target={uploaded ? "_blank" : undefined}
                className="group"
              >
                {uploaded ? <IoImageOutline /> : <IoCloudUploadOutline />}
                {getFilename(image)}
              </a>
              <button
                type="button"
                className="btn btn-icon remove-img-btn"
                onClick={() => removeImage(image)}
              >
                <IoCloseOutline />
              </button>
            </li>
          );
        })}
      </ul>
    </section>
  );
};
