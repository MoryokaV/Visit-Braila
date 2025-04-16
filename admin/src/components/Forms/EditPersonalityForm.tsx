import { SubmitHandler, useForm } from "react-hook-form";
import { InputField } from "./Fields/InputField";
import { PdfFormType } from "../../models/FormType";
import { createImagesFormData, getImagesToDelete } from "../../utils/images";
import { DescriptionField } from "./Fields/DescriptionField";
import { ImagesField } from "./Fields/ImagesField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { Personality } from "../../models/PersonalityModel";
import { PdfField } from "./Fields/PdfField";

interface Props {
  personality: Personality;
  updateTable: (updatedPersonality: Personality) => void;
  closeModal: () => void;
}

export const EditPersonalityForm: React.FC<Props> = ({
  personality,
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
  } = useForm<PdfFormType<Personality>>();

  const files = watch("files", []);
  const images = watch("images", [...personality.images]);

  const onSubmit: SubmitHandler<PdfFormType<Personality>> = async data => {
    // Check if sight_link is valid
    data.sight_link = data.sight_link!.trim();
    if (data.sight_link != "") {
      const sight = await fetch("/api/findSight/" + data.sight_link)
        .then(response => response.json())
        .catch(() => {});

      if (sight == undefined) {
        alert("ERROR: Sight doesn't exist!");
        return;
      }
    }

    const imagesFormData = new FormData();

    const { files, pdfFile, ...updatedPersonality } = data;
    let pdf_to_delete = null;

    if (pdfFile.length != 0) {
      const pdfFormData = new FormData();

      pdfFormData.append("pdfFile", pdfFile[0]);
      updatedPersonality.pdf = "/static/pdf/" + pdfFile[0].name;
      pdf_to_delete = personality.pdf;

      await fetch(`/api/uploadPDF`, {
        method: "POST",
        body: pdfFormData,
      }).then(response => {
        if (response.status === 413) {
          alert("Files size should be less than 15MB");
          throw new Error();
        }
      });
    } else {
      updatedPersonality.pdf = personality.pdf;
    }

    createImagesFormData(imagesFormData, files);

    if (files.length !== 0) {
      await fetch("/api/uploadImages/sights", {
        method: "POST",
        body: imagesFormData,
      }).then(response => {
        if (response.status === 413) {
          alert("Files size should be less than 15MB");
          throw new Error();
        }
      });
    }

    const images_to_delete = getImagesToDelete(
      personality.images,
      updatedPersonality.images,
    );

    await fetch("/api/editPersonality", {
      method: "PUT",
      body: JSON.stringify({
        images_to_delete,
        pdf_to_delete,
        _id: personality._id,
        personality: updatedPersonality,
      }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    updatedPersonality._id = personality._id;
    updateTable(updatedPersonality);

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
          defaultValue={personality.name}
        />
      </section>
      <section className="col-12">
        <label className="form-label">Description</label>
        <DescriptionField
          register={register}
          setValue={setValue}
          defaultValue={personality.description}
        />
      </section>
      <section className="col-12">
        <PdfField label="PDF" register={register} />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        setValue={setValue}
        collection="personalities"
      />
      <section className="col-12">
        <PrimaryImageField
          register={register}
          max={images && images.length}
          defaultValue={personality.primary_image}
        />
      </section>
      <section className="col-12">
        <InputField
          id="sight_link"
          label="Sight ID"
          register={register}
          type="text"
          defaultValue={personality.sight_link}
        />
        <div className="form-text">
          ID-ul casei memoriale corespunzătoare personalității
          <br />
          Dacă nu există se poate lăsa liber câmpul
        </div>
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
