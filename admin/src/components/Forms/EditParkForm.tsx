import { SubmitHandler, useForm } from "react-hook-form";
import { InputField } from "./Fields/InputField";
import { FormType } from "../../models/FormType";
import { Park } from "../../models/ParkModel";
import { createImagesFormData, getImagesToDelete } from "../../utils/images";
import { ImagesField } from "./Fields/ImagesField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { latitudeValidation, longitudeValidation } from "../../data/RegExpData";

interface Props {
  park: Park;
  updateTable: (updatedPark: Park) => void;
  closeModal: () => void;
}

export const EditParkForm: React.FC<Props> = ({ park, updateTable, closeModal }) => {
  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Park>>();

  const files = watch("files", []);
  const images = watch("images", [...park.images]);

  const onSubmit: SubmitHandler<FormType<Park>> = async data => {
    const formData = new FormData();
    const { files, ...updatedPark } = data;

    createImagesFormData(formData, files);

    if (files.length !== 0) {
      await fetch("/api/uploadImages/parks", {
        method: "POST",
        body: formData,
      }).then(response => {
        if (response.status === 413) {
          alert("Files size should be less than 15MB");
          throw new Error();
        }
      });
    }

    const images_to_delete = getImagesToDelete(park.images, updatedPark.images);

    await fetch("/api/editPark", {
      method: "PUT",
      body: JSON.stringify({
        images_to_delete,
        _id: park._id,
        park: updatedPark,
      }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    updatedPark._id = park._id;
    updateTable(updatedPark);

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
          defaultValue={park.name}
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
          defaultValue={park.latitude}
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
          defaultValue={park.longitude}
          {...longitudeValidation}
        />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        setValue={setValue}
        collection="parks"
      />
      <section className="col-12">
        <PrimaryImageField
          register={register}
          max={images && images.length}
          defaultValue={park.primary_image}
        />
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
