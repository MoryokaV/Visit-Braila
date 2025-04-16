import "react-quill/dist/quill.snow.css";
import { DescriptionField } from "./Fields/DescriptionField";
import {
  SubmitHandler,
  UseFormHandleSubmit,
  UseFormRegister,
  UseFormSetValue,
} from "react-hook-form";
import { Personality } from "../../models/PersonalityModel";
import { InputField } from "./Fields/InputField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { ImagesField } from "./Fields/ImagesField";
import { PdfFormType } from "../../models/FormType";
import { createImagesFormData } from "../../utils/images";
import { useState } from "react";
import { PdfField } from "./Fields/PdfField";

interface Props {
  register: UseFormRegister<any>;
  handleSubmit: UseFormHandleSubmit<PdfFormType<Personality>, undefined>;
  setValue: UseFormSetValue<any>;
  resetForm: () => void;
  isSubmitting: boolean;
  images: Array<string>;
  files: File[];
  description: string;
}

export const InsertPersonalityForm: React.FC<Props> = ({
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

    const imageFormData = new FormData();
    const pdfFormData = new FormData();

    const { files, pdfFile, ...personality } = data;

    pdfFormData.append("pdfFile", pdfFile[0]);
    personality.pdf = "/static/pdf/" + pdfFile[0].name;

    await fetch(`/api/uploadPDF`, {
      method: "POST",
      body: pdfFormData,
    }).then(response => {
      if (response.status === 413) {
        alert("Files size should be less than 15MB");
        throw new Error();
      }
    });

    createImagesFormData(imageFormData, files);

    await fetch("/api/uploadImages/personalities", {
      method: "POST",
      body: imageFormData,
    }).then(response => {
      if (response.status === 413) {
        alert("Files size should be less than 15MB");
        throw new Error();
      }
    });

    await fetch("/api/insertPersonality", {
      method: "POST",
      body: JSON.stringify(personality),
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
      <section className="col-12">
        <PdfField label="PDF" register={register} required />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        collection="personalities"
        setValue={setValue}
      />
      <section className="col-12">
        <PrimaryImageField register={register} max={files && files.length} />
      </section>
      <section className="col-12">
        <InputField id="sight_link" label="Sight ID" register={register} type="text" />
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
          <span>Insert</span>
        </button>
      </section>
    </form>
  );
};
