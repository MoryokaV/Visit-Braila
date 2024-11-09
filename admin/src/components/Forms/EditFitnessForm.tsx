import { SubmitHandler, useForm } from "react-hook-form";
import { InputField } from "./Fields/InputField";
import { FormType } from "../../models/FormType";
import { Fitness } from "../../models/FitnessModel";
import { createImagesFormData, getImagesToDelete } from "../../utils/images";
import { DescriptionField } from "./Fields/DescriptionField";
import { ImagesField } from "./Fields/ImagesField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { latitudeValidation, longitudeValidation } from "../../data/RegExpData";

interface Props {
  fitness: Fitness;
  updateTable: (updatedFitness: Fitness) => void;
  closeModal: () => void;
}

export const EditFitnessForm: React.FC<Props> = ({
  fitness,
  updateTable,
  closeModal,
}) => {
  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Fitness>>();

  const files = watch("files", []);
  const images = watch("images", [...fitness.images]);

  const onSubmit: SubmitHandler<FormType<Fitness>> = async data => {
    const formData = new FormData();
    const { files, ...updatedFitness } = data;

    createImagesFormData(formData, files);

    if (files.length !== 0) {
      await fetch("/api/uploadImages/fitness", {
        method: "POST",
        body: formData,
      }).then(response => {
        if (response.status === 413) {
          alert("Files size should be less than 15MB");
          throw new Error();
        }
      });
    }

    const images_to_delete = getImagesToDelete(fitness.images, updatedFitness.images);

    await fetch("/api/editFitness", {
      method: "PUT",
      body: JSON.stringify({
        images_to_delete,
        _id: fitness._id,
        fitness: updatedFitness,
      }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    updatedFitness._id = fitness._id;
    updateTable(updatedFitness);

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
          defaultValue={fitness.name}
        />
      </section>

      <section className="col-12">
        <label className="form-label">Description</label>
        <DescriptionField
          register={register}
          setValue={setValue}
          defaultValue={fitness.description}
        />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        setValue={setValue}
        collection="fitness"
      />
      <section className="col-12">
        <PrimaryImageField
          register={register}
          max={images && images.length}
          defaultValue={fitness.primary_image}
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
          defaultValue={fitness.latitude}
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
          defaultValue={fitness.longitude}
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
          defaultValue={fitness.external_link}
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
