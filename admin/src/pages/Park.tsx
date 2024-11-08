import { useForm } from "react-hook-form";
import { Park } from "../models/ParkModel";
import { useEffect, useState } from "react";
import { getBase64 } from "../utils/images";
import { FormType } from "../models/FormType";
import Card from "../components/Card";
import { InsertParkForm } from "../components/Forms/InsertParkForm";

export default function ParkPage() {
  const [previewBlobs, setPreviewBlobs] = useState<Array<string>>([]);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Park>>();

  const park = watch();

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
    files: park.files,
    images: park.images,
  };

  useEffect(() => {
    if (park.files) {
      processPreviewImages();
    }
  }, [park.files]);

  const processPreviewImages = async () => {
    const blobs: Array<string> = await Promise.all(
      Array.from(park.files).map(file => getBase64(file)),
    );

    setPreviewBlobs(blobs);
  };

  return (
    <div className="d-flex h-100">
      <div className="container-sm m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-lg-8">
            <Card title="Insert park">
              <InsertParkForm {...formProps} />
            </Card>
          </div>
          <div className="col-sm-10 col-lg-4">
            <p className="preview-title">Live preview</p>
            <div
              className="card"
              style={{
                backgroundImage: `url(${previewBlobs && previewBlobs[park.primary_image - 1]})`,
                backgroundRepeat: "no-repeat",
                backgroundSize: "cover",
                height: "450px",
                overflow: "hidden",
              }}
            >
              <section
                className="card-body"
                style={{
                  width: "100%",
                  position: "absolute",
                  bottom: "0",
                  backdropFilter: "blur(10px)",
                }}
              >
                <h4 className="card-title" style={{ color: "#fff" }}>
                  {park.name}
                </h4>
              </section>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
