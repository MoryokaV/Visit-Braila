import { useForm } from "react-hook-form";
import { useEffect, useState } from "react";
import { getBase64 } from "../utils/images";
import Card from "../components/Card";
import { InsertEventForm } from "../components/Forms/InsertEventForm";
import { FormType } from "../models/FormType";
import { Event } from "../models/EventModel";

type EventFormType = { notify: boolean } & FormType<Event>;

export default function EventPage() {
  const [previewBlobs, setPreviewBlobs] = useState<Array<string>>([]);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    getValues,
    watch,
  } = useForm<EventFormType>();

  const event = watch();

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
    getValues,
    files: event.files,
    images: event.images,
    description: event.description,
  };

  useEffect(() => {
    if (event.files) {
      processPreviewImages();
    }
  }, [event.files]);

  const processPreviewImages = async () => {
    const blobs: Array<string> = await Promise.all(
      Array.from(event.files).map(file => getBase64(file)),
    );

    setPreviewBlobs(blobs);
  };

  return (
    <div className="d-flex h-100">
      <div className="container-sm m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-lg-8">
            <Card title="Insert event">
              <InsertEventForm {...formProps} />
            </Card>
          </div>
          <div className="col-sm-10 col-lg-4">
            <p className="preview-title">Live preview</p>
            <div className="card">
              <img
                className="card-img-top"
                src={previewBlobs && previewBlobs[event.primary_image - 1]}
              />
              <section className="card-body preview-body">
                <h4 className="card-title">{event.name}</h4>
                <div
                  className="card-text"
                  dangerouslySetInnerHTML={{ __html: event.description }}
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
