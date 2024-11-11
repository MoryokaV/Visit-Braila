import {
  SubmitHandler,
  UseFormHandleSubmit,
  UseFormRegister,
  UseFormSetValue,
} from "react-hook-form";
import { latitudeValidation, longitudeValidation } from "../../data/RegExpData";
import { Park } from "../../models/ParkModel";
import { InputField } from "./Fields/InputField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { ImagesField } from "./Fields/ImagesField";
import { FormType } from "../../models/FormType";
import { createImagesFormData } from "../../utils/images";
import { useState } from "react";

interface Props {
  register: UseFormRegister<any>;
  handleSubmit: UseFormHandleSubmit<FormType<Park>, undefined>;
  setValue: UseFormSetValue<any>;
  resetForm: () => void;
  isSubmitting: boolean;
  images: Array<string>;
  files: File[];
}

export const InsertParkForm: React.FC<Props> = ({
  register,
  handleSubmit,
  resetForm,
  setValue,
  isSubmitting,
  images,
  files,
}) => {
  const [key, setKey] = useState(0);

  const onSubmit: SubmitHandler<FormType<Park>> = async data => {
    const formData = new FormData();
    const { files, ...park } = data;

    createImagesFormData(formData, files);

    await fetch("/api/uploadImages/parks", {
      method: "POST",
      body: formData,
    }).then(response => {
      if (response.status === 413) {
        alert("Files size should be less than 15MB");
        throw new Error();
      }
    });

    await fetch("/api/insertPark", {
      method: "POST",
      body: JSON.stringify(park),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    resetForm();
    setKey(key + 1);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="row g-3" key={key}>
      <section className="col-12">
        <InputField
          id="name"
          label="Name"
          register={register}
          type="text"
          required
          maxLength={60}
        />
      </section>
      <section className="col-sm-6">
        <InputField
          id="latitude"
          label="Latitude"
          register={register}
          type="text"
          required
          valueAsNumber={true}
          {...latitudeValidation}
        />
      </section>
      <section className="col-sm-6">
        <InputField
          id="longitude"
          label="Longitude"
          register={register}
          type="text"
          required
          valueAsNumber={true}
          {...longitudeValidation}
        />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        collection="parks"
        setValue={setValue}
      />
      <section className="col-12">
        <PrimaryImageField register={register} max={files && files.length} />
      </section>
      <section className="col-12 d-flex gap-3 align-items-center flex-wrap">
        <span>Type </span>
        <div className="form-check form-check-inline">
          <input
            className="form-check-input"
            type="radio"
            value="relaxare"
            id="type-relaxare"
            {...register("type")}
            defaultChecked
          />
          <label className="form-check-label" htmlFor="type-public"></label>
          relaxare
        </div>
        <div className="form-check form-check-inline">
          <input
            className="form-check-input"
            type="radio"
            value="joaca"
            id="type-joaca"
            {...register("type")}
          />
          <label className="form-check-label" htmlFor="type-privat">
            joacă
          </label>
        </div>
        <div className="form-check form-check-inline">
          <input
            className="form-check-input"
            type="radio"
            value="fitness"
            id="type-fitness"
            {...register("type")}
          />
          <label className="form-check-label" htmlFor="type-privat">
            fitness
          </label>
        </div>
      </section>
      <section className="col-12">
        <button
          type="submit"
          className={`btn btn-primary ${isSubmitting && "loading-btn"}`}
        >
          <span>Insert</span>
        </button>
      </section>
    </form>
  );
};
