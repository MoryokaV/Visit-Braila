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
import { MadeInBraila } from "../../models/MadeInBrailaModel";

interface Props {
  madeInBraila: MadeInBraila;
  updateTable: (updatedMadeInBraila: MadeInBraila) => void;
  closeModal: () => void;
}

export const EditMadeInBrailaForm: React.FC<Props> = ({
  madeInBraila,
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
  } = useForm<FormType<MadeInBraila>>();

  const files = watch("files", []);
  const images = watch("images", [...madeInBraila.images]);
  const activeTags = watch("tags", [...madeInBraila.tags]);

  const onSubmit: SubmitHandler<FormType<MadeInBraila>> = async data => {
    const formData = new FormData();
    const { files, ...updatedMadeInBraila } = data;

    createImagesFormData(formData, files);

    if (files.length !== 0) {
      await fetch("/api/uploadImages/madeinbraila", {
        method: "POST",
        body: formData,
      }).then(response => {
        if (response.status === 413) {
          alert("Files size should be less than 15MB");
          throw new Error();
        }
      });
    }

    const images_to_delete = getImagesToDelete(
      madeInBraila.images,
      updatedMadeInBraila.images,
    );

    await fetch("/api/editMadeInBraila", {
      method: "PUT",
      body: JSON.stringify({
        images_to_delete: images_to_delete,
        _id: madeInBraila._id,
        madeInBraila: updatedMadeInBraila,
      }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    updatedMadeInBraila._id = madeInBraila._id;
    updateTable(updatedMadeInBraila);

    closeModal();

    reset();
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="row g-3">
      <section className="col-sm-7">
        <InputField
          id="name"
          label="Name"
          register={register}
          type="text"
          required
          maxLength={60}
          defaultValue={madeInBraila.name}
        />
      </section>
      <section className="col-sm-5">
        <InputField
          id="phone"
          label="Phone number"
          register={register}
          type="text"
          required
          maxLength={60}
          defaultValue={madeInBraila.phone}
          {...phoneValidation}
        />
      </section>
      <TagsField
        collection="madeinbraila"
        register={register}
        setValue={setValue}
        activeTags={activeTags}
      />
      <section className="col-12">
        <label className="form-label">Description</label>
        <DescriptionField
          register={register}
          setValue={setValue}
          defaultValue={madeInBraila.description}
        />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        setValue={setValue}
        collection="madeinbraila"
      />
      <section className="col-12">
        <PrimaryImageField
          register={register}
          max={images && images.length}
          defaultValue={madeInBraila.primary_image}
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
          defaultValue={madeInBraila.latitude}
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
          defaultValue={madeInBraila.longitude}
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
          defaultValue={madeInBraila.external_link}
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
