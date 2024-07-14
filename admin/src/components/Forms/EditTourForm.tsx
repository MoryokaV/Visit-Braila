import { SubmitHandler, useForm } from "react-hook-form";
import { InputField } from "./Fields/InputField";
import { FormType } from "../../models/FormType";
import { createImagesFormData, getImagesToDelete } from "../../utils/images";
import { DescriptionField } from "./Fields/DescriptionField";
import { ImagesField } from "./Fields/ImagesField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { Tour } from "../../models/TourModel";
import { StagesField } from "./Fields/StagesField";
import { LengthField } from "./Fields/LengthField";

interface Props {
  tour: Tour;
  updateTable: (updatedTour: Tour) => void;
  closeModal: () => void;
}

export const EditTourForm: React.FC<Props> = ({ tour, updateTable, closeModal }) => {
  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Tour>>();

  const files = watch("files", []);
  const images = watch("images", [...tour.images]);
  const stages = watch("stages", [...tour.stages]);

  const onSubmit: SubmitHandler<FormType<Tour>> = async data => {
    const formData = new FormData();
    const { files, ...updatedTour } = data;

    createImagesFormData(formData, files);

    if (files.length !== 0) {
      await fetch("/api/uploadImages/tours", {
        method: "POST",
        body: formData,
      }).then(response => {
        if (response.status === 413) {
          alert("Files size should be less than 15MB");
          throw new Error();
        }
      });
    }
    const images_to_delete = getImagesToDelete(tour.images, updatedTour.images);

    await fetch("/api/editTour", {
      method: "PUT",
      body: JSON.stringify({
        images_to_delete: images_to_delete,
        _id: tour._id,
        tour: updatedTour,
      }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    updatedTour._id = tour._id;
    updateTable(updatedTour);

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
          defaultValue={tour.name}
        />
      </section>
      <StagesField register={register} setValue={setValue} stages={stages} />
      <section className="col-12">
        <label className="form-label">Description</label>
        <DescriptionField
          register={register}
          setValue={setValue}
          defaultValue={tour.description}
        />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        collection="tours"
        setValue={setValue}
      />
      <section className="col-12">
        <PrimaryImageField
          register={register}
          max={images && images.length}
          defaultValue={tour.primary_image}
        />
      </section>
      <LengthField register={register} defaultValue={tour.length} />
      <section className="col-12">
        <InputField
          id="external_link"
          label="External link"
          register={register}
          type="url"
          required
          defaultValue={tour.external_link}
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
