import "react-quill/dist/quill.snow.css";
import { DescriptionField } from "./Fields/DescriptionField";
import {
  SubmitHandler,
  UseFormHandleSubmit,
  UseFormRegister,
  UseFormSetValue,
} from "react-hook-form";
import {
  latitudeValidation,
  longitudeValidation,
  phoneValidation,
} from "../../data/RegExpData";
import { TagsField } from "./Fields/TagsField";
import { InputField } from "./Fields/InputField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { ImagesField } from "./Fields/ImagesField";
import { FormType } from "../../models/FormType";
import { createImagesFormData } from "../../utils/images";
import { Hotel } from "../../models/HotelModel";

interface Props {
  register: UseFormRegister<any>;
  handleSubmit: UseFormHandleSubmit<FormType<Hotel>, undefined>;
  setValue: UseFormSetValue<any>;
  resetForm: () => void;
  isSubmitting: boolean;
  images: Array<string>;
  files: File[];
  activeTags: Array<string>;
  description: string;
}

export const InsertHotelForm: React.FC<Props> = ({
  register,
  handleSubmit,
  resetForm,
  setValue,
  isSubmitting,
  images,
  files,
  activeTags,
  description,
}) => {
  const onSubmit: SubmitHandler<FormType<Hotel>> = async data => {
    const formData = new FormData();
    const { files, ...hotel } = data;

    createImagesFormData(formData, files);

    await fetch("/api/uploadImages/hotels", {
      method: "POST",
      body: formData,
    }).then(response => {
      if (response.status === 413) {
        alert("Files size should be less than 15MB");
        throw new Error();
      }
    });

    await fetch("/api/insertHotel", {
      method: "POST",
      body: JSON.stringify(hotel),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    resetForm();
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="row g-3">
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
          id="stars"
          label="Stars"
          register={register}
          type="number"
          required
          valueAsNumber={true}
          defaultValue={1}
          min={1}
          max={5}
        />
      </section>
      <section className="col-sm-6">
        <InputField
          id="phone"
          label="Phone number"
          register={register}
          type="text"
          required
          valueAsNumber={false}
          {...phoneValidation}
        />
      </section>
      <TagsField
        collection="hotels"
        register={register}
        setValue={setValue}
        activeTags={activeTags}
      />
      <section className="col-12">
        <label className="form-label">Description</label>
        <DescriptionField register={register} setValue={setValue} value={description} />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        collection="hotels"
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
