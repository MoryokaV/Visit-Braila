import { useForm } from "react-hook-form";
import { Personality } from "../models/PersonalityModel";
import { InsertPersonalityForm } from "../components/Forms/InsertPersonalityForm";
import { useEffect, useState } from "react";
import { getBase64 } from "../utils/images";
import { PdfFormType } from "../models/FormType";
import Card from "../components/Card";

export default function PersonalityPage() {
  const [previewBlobs, setPreviewBlobs] = useState<Array<string>>([]);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<PdfFormType<Personality>>();

  const personality = watch();

  const resetForm = () => {
    setPreviewBlobs([]);
    reset();
  };

  const formProps = {
    register,
    handleSubmit,
    isSubmitting,
    resetForm,
    setValue,
    files: personality.files,
    images: personality.images,
    description: personality.description,
  };

  useEffect(() => {
    if (personality.files) {
      processPreviewImages();
    }
  }, [personality.files]);

  const processPreviewImages = async () => {
    const blobs: Array<string> = await Promise.all(
      Array.from(personality.files).map(file => getBase64(file)),
    );

    setPreviewBlobs(blobs);
  };

  return (
    <div className="d-flex h-100">
      <div className="container-sm m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-lg-8">
            <Card title="Insert sight">
              <InsertPersonalityForm {...formProps} />
            </Card>
          </div>
          <div className="col-sm-10 col-lg-4">
            <p className="preview-title">Live preview</p>
            <div className="card">
              <img
                className="card-img-top"
                src={previewBlobs && previewBlobs[personality.primary_image - 1]}
              />
              <section className="card-body preview-body">
                <h4 className="card-title">{personality.name}</h4>
                <div
                  className="card-text"
                  dangerouslySetInnerHTML={{ __html: personality.description }}
                ></div>
                <footer className="d-flex align-items-center gap-2">
                  {previewBlobs.map((blob, index) => (
                    <img key={index} src={blob} />
                  ))}
                </footer>
              </section>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
