import { SubmitHandler, useForm } from "react-hook-form";
import { InputField } from "./Fields/InputField";
import { FormType } from "../../models/FormType";
import { createImagesFormData, getImagesToDelete } from "../../utils/images";
import { TagsField } from "./Fields/TagsField";
import { DescriptionField } from "./Fields/DescriptionField";
import { ImagesField } from "./Fields/ImagesField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import {
  latitudeValidation,
  longitudeValidation,
  phoneValidation,
} from "../../data/RegExpData";
import { Hotel } from "../../models/HotelModel";

interface Props {
  hotel: Hotel;
  updateTable: (updatedHotel: Hotel) => void;
  closeModal: () => void;
}

export const EditHotelForm: React.FC<Props> = ({ hotel, updateTable, closeModal }) => {
  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Hotel>>();

  const files = watch("files", []);
  const images = watch("images", [...hotel.images]);
  const activeTags = watch("tags", [...hotel.tags]);

  const onSubmit: SubmitHandler<FormType<Hotel>> = async data => {
    const formData = new FormData();
    const { files, ...updatedHotel } = data;

    createImagesFormData(formData, files);

    if (files.length !== 0) {
      await fetch("/api/uploadImages/hotels", {
        method: "POST",
        body: formData,
      }).then(response => {
        if (response.status === 413) {
          alert("Files size should be less than 15MB");
          throw new Error();
        }
      });
    }

    const images_to_delete = getImagesToDelete(hotel.images, updatedHotel.images);

    await fetch("/api/editHotel", {
      method: "PUT",
      body: JSON.stringify({
        images_to_delete,
        _id: hotel._id,
        hotel: updatedHotel,
      }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    updatedHotel._id = hotel._id;
    updateTable(updatedHotel);

    closeModal();

    reset();
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
          defaultValue={hotel.name}
        />
      </section>
      <section className="col-6">
        <InputField
          id="stars"
          label="Stars"
          register={register}
          type="number"
          required
          valueAsNumber={true}
          defaultValue={hotel.stars}
          min={1}
          max={5}
        />
      </section>
      <section className="col-6">
        <InputField
          id="phone"
          label="Phone number"
          register={register}
          type="text"
          required
          valueAsNumber={false}
          defaultValue={hotel.phone}
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
        <DescriptionField
          register={register}
          setValue={setValue}
          defaultValue={hotel.description}
        />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        setValue={setValue}
        collection="hotels"
      />
      <section className="col-12">
        <PrimaryImageField
          register={register}
          max={images && images.length}
          defaultValue={hotel.primary_image}
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
          defaultValue={hotel.latitude}
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
          defaultValue={hotel.longitude}
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
          defaultValue={hotel.external_link}
        />
        <div className="form-text">Note: it must be a website URL</div>
      </section>
      <section className="col-12">
        <button
          type="submit"
          className={`btn btn-primary ${isSubmitting && "loading-btn"}`}
        >
          <span>Save</span>
        </button>
      </section>
    </form>
  );
};
