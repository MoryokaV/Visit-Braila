import { useForm } from "react-hook-form";
import { Fitness } from "../models/FitnessModel";
import { InsertFitnessForm } from "../components/Forms/InsertFitnessForm";
import { useEffect, useState } from "react";
import { getBase64 } from "../utils/images";
import { FormType } from "../models/FormType";
import Card from "../components/Card";

export default function FitnessPage() {
  const [previewBlobs, setPreviewBlobs] = useState<Array<string>>([]);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Fitness>>();

  const fitness = watch();

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
    files: fitness.files,
    images: fitness.images,
    description: fitness.description,
  };

  useEffect(() => {
    if (fitness.files) {
      processPreviewImages();
    }
  }, [fitness.files]);

  const processPreviewImages = async () => {
    const blobs: Array<string> = await Promise.all(
      Array.from(fitness.files).map(file => getBase64(file)),
    );

    setPreviewBlobs(blobs);
  };

  return (
    <div className="d-flex h-100">
      <div className="container-sm m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-lg-8">
            <Card title="Insert fitness & wellness">
              <InsertFitnessForm {...formProps} />
            </Card>
          </div>
          <div className="col-sm-10 col-lg-4">
            <p className="preview-title">Live preview</p>
            <div className="card">
              <img
                className="card-img-top"
                src={previewBlobs && previewBlobs[fitness.primary_image - 1]}
              />
              <section className="card-body preview-body">
                <h4 className="card-title">{fitness.name}</h4>
                <div
                  className="card-text"
                  dangerouslySetInnerHTML={{ __html: fitness.description }}
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
