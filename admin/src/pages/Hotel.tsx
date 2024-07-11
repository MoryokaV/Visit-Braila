import { useForm } from "react-hook-form";
import { useEffect, useState } from "react";
import { getBase64 } from "../utils/images";
import { FormType } from "../models/FormType";
import Card from "../components/Card";
import { Hotel } from "../models/HotelModel";
import { InsertHotelForm } from "../components/Forms/InsertHotelForm";

export default function HotelPage() {
  const [previewBlobs, setPreviewBlobs] = useState<Array<string>>([]);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Hotel>>();

  const hotel = watch();

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
    files: hotel.files,
    images: hotel.images,
    activeTags: hotel.tags,
    description: hotel.description,
  };

  useEffect(() => {
    if (hotel.files) {
      processPreviewImages();
    }
  }, [hotel.files]);

  const processPreviewImages = async () => {
    const blobs: Array<string> = await Promise.all(
      Array.from(hotel.files).map(file => getBase64(file)),
    );

    setPreviewBlobs(blobs);
  };

  return (
    <div className="d-flex h-100">
      <div className="container-sm m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-lg-8">
            <Card title="Insert hotel">
              <InsertHotelForm {...formProps} />
            </Card>
          </div>
          <div className="col-sm-10 col-lg-4">
            <p className="preview-title">Live preview</p>
            <div className="card">
              <img
                className="card-img-top"
                src={previewBlobs && previewBlobs[hotel.primary_image - 1]}
              />
              <section className="card-body preview-body">
                <h4 className="card-title">{hotel.name}</h4>
                <div className="d-flex align-items-center flex-wrap gap-2">
                  <div className="stars" style={{ marginBottom: 0 }}>
                    {"★".repeat(hotel.stars ? hotel.stars : 1)}
                  </div>
                  <div
                    className="d-flex align-items-center flex-wrap"
                    style={{ marginBottom: 0 }}
                  >
                    {hotel.tags &&
                      hotel.tags.map((tag, index) => {
                        return (
                          <p key={index}>
                            {tag}
                            {index != hotel.tags.length - 1 ? ", " : " "}
                          </p>
                        );
                      })}
                  </div>
                </div>

                <div
                  className="card-text"
                  dangerouslySetInnerHTML={{ __html: hotel.description }}
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
