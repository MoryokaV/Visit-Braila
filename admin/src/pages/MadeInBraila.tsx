import { useForm } from "react-hook-form";
import { useEffect, useState } from "react";
import { getBase64 } from "../utils/images";
import { FormType } from "../models/FormType";
import Card from "../components/Card";
import { MadeInBraila } from "../models/MadeInBrailaModel";
import { InsertMadeInBrailaForm } from "../components/Forms/InsertMadeInBrailaForm";

export default function MadeInBrailaPage() {
  const [previewBlobs, setPreviewBlobs] = useState<Array<string>>([]);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<MadeInBraila>>();

  const madeInBraila = watch();

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
    files: madeInBraila.files,
    images: madeInBraila.images,
    activeTags: madeInBraila.tags,
    description: madeInBraila.description,
  };

  useEffect(() => {
    if (madeInBraila.files) {
      processPreviewImages();
    }
  }, [madeInBraila.files]);

  const processPreviewImages = async () => {
    const blobs: Array<string> = await Promise.all(
      Array.from(madeInBraila.files).map(file => getBase64(file)),
    );

    setPreviewBlobs(blobs);
  };

  return (
    <div className="d-flex h-100">
      <div className="container-sm m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-lg-8">
            <Card title="Insert Made In Brăila">
              <InsertMadeInBrailaForm {...formProps} />
            </Card>
          </div>
          <div className="col-sm-10 col-lg-4">
            <p className="preview-title">Live preview</p>
            <div className="card">
              <img
                className="card-img-top"
                src={previewBlobs && previewBlobs[madeInBraila.primary_image - 1]}
              />
              <section className="card-body preview-body">
                <h4 className="card-title">{madeInBraila.name}</h4>
                <div className="d-flex align-items-center flex-wrap">
                  {madeInBraila.tags &&
                    madeInBraila.tags.map((tag, index) => {
                      return (
                        <p key={index}>
                          {tag}
                          {index != madeInBraila.tags.length - 1 ? ", " : " "}
                        </p>
                      );
                    })}
                </div>
                <div
                  className="card-text"
                  dangerouslySetInnerHTML={{ __html: madeInBraila.description }}
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
