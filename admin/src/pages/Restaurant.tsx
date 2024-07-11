import { useForm } from "react-hook-form";
import { useEffect, useState } from "react";
import { getBase64 } from "../utils/images";
import { FormType } from "../models/FormType";
import Card from "../components/Card";
import { Restaurant } from "../models/RestaurantModel";
import { InsertRestaurantForm } from "../components/Forms/InsertRestaurantForm";

export default function RestaurantPage() {
  const [previewBlobs, setPreviewBlobs] = useState<Array<string>>([]);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Restaurant>>();

  const restaurant = watch();

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
    files: restaurant.files,
    images: restaurant.images,
    activeTags: restaurant.tags,
    description: restaurant.description,
  };

  useEffect(() => {
    if (restaurant.files) {
      processPreviewImages();
    }
  }, [restaurant.files]);

  const processPreviewImages = async () => {
    const blobs: Array<string> = await Promise.all(
      Array.from(restaurant.files).map(file => getBase64(file)),
    );

    setPreviewBlobs(blobs);
  };

  return (
    <div className="d-flex h-100">
      <div className="container-sm m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-lg-8">
            <Card title="Insert restaurant">
              <InsertRestaurantForm {...formProps} />
            </Card>
          </div>
          <div className="col-sm-10 col-lg-4">
            <p className="preview-title">Live preview</p>
            <div className="card">
              <img
                className="card-img-top"
                src={previewBlobs && previewBlobs[restaurant.primary_image - 1]}
              />
              <section className="card-body preview-body">
                <h4 className="card-title">{restaurant.name}</h4>
                <div className="d-flex align-items-center flex-wrap">
                  {restaurant.tags &&
                    restaurant.tags.map((tag, index) => {
                      return (
                        <p key={index}>
                          {tag}
                          {index != restaurant.tags.length - 1 ? ", " : " "}
                        </p>
                      );
                    })}
                </div>
                <div
                  className="card-text"
                  dangerouslySetInnerHTML={{ __html: restaurant.description }}
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
