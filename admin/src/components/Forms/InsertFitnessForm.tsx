import "react-quill/dist/quill.snow.css";
import { DescriptionField } from "./Fields/DescriptionField";
import {
  SubmitHandler,
  UseFormHandleSubmit,
  UseFormRegister,
  UseFormSetValue,
} from "react-hook-form";
import { latitudeValidation, longitudeValidation } from "../../data/RegExpData";
import { Fitness } from "../../models/FitnessModel";
import { InputField } from "./Fields/InputField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { ImagesField } from "./Fields/ImagesField";
import { FormType } from "../../models/FormType";
import { createImagesFormData } from "../../utils/images";
import { useState } from "react";

interface Props {
  register: UseFormRegister<any>;
  handleSubmit: UseFormHandleSubmit<FormType<Fitness>, undefined>;
  setValue: UseFormSetValue<any>;
  resetForm: () => void;
  isSubmitting: boolean;
  images: Array<string>;
  files: File[];
  description: string;
}

export const InsertFitnessForm: React.FC<Props> = ({
  register,
  handleSubmit,
  resetForm,
  setValue,
  isSubmitting,
  images,
  files,
  description,
}) => {
  const [key, setKey] = useState(0);

  const onSubmit: SubmitHandler<FormType<Fitness>> = async data => {
    const formData = new FormData();
    const { files, ...fitness } = data;

    createImagesFormData(formData, files);

    await fetch("/api/uploadImages/fitness", {
      method: "POST",
      body: formData,
    }).then(response => {
      if (response.status === 413) {
        alert("Files size should be less than 15MB");
        throw new Error();
      }
    });

    await fetch("/api/insertFitness", {
      method: "POST",
      body: JSON.stringify(fitness),
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
      <section className="col-12">
        <label className="form-label">Description</label>
        <DescriptionField register={register} setValue={setValue} value={description} />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        collection="fitness"
        setValue={setValue}
      />
      <section className="col-12">
        <PrimaryImageField register={register} max={files && files.length} />
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
      <section className="col-12">
        <InputField
          id="external_link"
          label="External link"
          register={register}
          type="url"
          required
        />
        <div className="form-text">Note: it must be a website URL</div>
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
