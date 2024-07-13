import React, { useEffect, useState } from "react";
import { FieldValues, SubmitHandler, useForm } from "react-hook-form";
import ReactQuill from "react-quill";
import { LoadingSpinner } from "../components/LoadingSpinner";
import { About } from "../models/AboutModel";
import { IoCloseOutline, IoCloudUploadOutline, IoImageOutline } from "react-icons/io5";
import Card from "../components/Card";
import { getFilename } from "../utils/images";
import { phoneValidation } from "../data/RegExpData";

export default function AboutPage() {
  const [isLoading, setLoading] = useState(true);
  const [about, setAbout] = useState<About>();

  useEffect(() => {
    fetch("/api/fetchAboutData")
      .then(response => response.json())
      .then(data => {
        setAbout(data);
        setLoading(false);
      });
  }, []);

  return (
    <div className="d-flex h-100">
      <div className="container-sm m-auto py-3">
        <h2 className="tab-title">Tell something about you & your app</h2>

        <div className="row justify-content-center gx-4 gy-3 mt-3 px-2">
          {isLoading ? (
            <LoadingSpinner />
          ) : (
            <>
              <HelpCard paragraph1={about!.paragraph1} paragraph2={about!.paragraph2} />
              <ContanctCard
                organization1={about!.organization1}
                organization2={about!.organization2}
                phone={about!.phone}
                email={about!.email}
                website1={about!.website1}
                website2={about!.website2}
                facebook1={about!.facebook1}
                facebook2={about!.facebook2}
              />
              <CoverImageCard defaultValue={about!.cover_image} />
            </>
          )}
        </div>
      </div>
    </div>
  );
}

interface HelpCardProps {
  paragraph1: string;
  paragraph2: string;
}

const HelpCard: React.FC<HelpCardProps> = ({ paragraph1, paragraph2 }) => {
  const theme = "snow";
  const placeholder = "Type something here...";

  const {
    register,
    setValue,
    handleSubmit,
    formState: { isSubmitting },
  } = useForm();

  useEffect(() => {
    register("paragraph1");
    setValue("paragraph1", paragraph1);

    register("paragraph2");
    setValue("paragraph2", paragraph2);
  }, [register, setValue]);

  const onSubmit: SubmitHandler<FieldValues> = async data => {
    await fetch("/api/updateAbout", {
      method: "PUT",
      body: JSON.stringify(data),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });
  };

  return (
    <div className="col-xl-6">
      <Card title="Help">
        <form id="paragraphs-form" className="row g-3" onSubmit={handleSubmit(onSubmit)}>
          <section className="col-12">
            <label htmlFor="paragraph-1-heading" className="form-label">
              Despre Visit Brăila
            </label>

            <ReactQuill
              defaultValue={paragraph2}
              theme={theme}
              placeholder={placeholder}
              onChange={(editorState: string) => {
                setValue("paragraph2", editorState);
              }}
            />
            <div id="paragraph-2-content"></div>
          </section>
          <section className="col-12">
            <label className="form-label">Instituții partenere</label>

            <ReactQuill
              defaultValue={paragraph1}
              theme={theme}
              placeholder={placeholder}
              onChange={(editorState: string) => {
                setValue("paragraph1", editorState);
              }}
            />
            <div id="paragraph-1-content"></div>
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
      </Card>
    </div>
  );
};

interface ContanctCardProps {
  organization1: string;
  organization2: string;
  phone: string;
  email: string;
  website1: string;
  website2: string;
  facebook1: string;
  facebook2: string;
}

const ContanctCard: React.FC<ContanctCardProps> = ({
  organization1,
  organization2,
  phone,
  email,
  website1,
  website2,
  facebook1,
  facebook2,
}) => {
  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
  } = useForm();

  const onSubmit: SubmitHandler<FieldValues> = async data => {
    await fetch("/api/updateAbout", {
      method: "PUT",
      body: JSON.stringify(data),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });
  };

  return (
    <div className="col-xl-6">
      <Card title="Contact">
        <form id="contact-form" className="row g-3" onSubmit={handleSubmit(onSubmit)}>
          <section className="col-12">
            <div className="row gx-3 gy-0">
              <label htmlFor="organization" className="col-sm-3 form-label">
                Organization
              </label>
              <div className="col">
                <input
                  type="text"
                  id="organization"
                  className="form-control"
                  defaultValue={organization1}
                  required
                  {...register("organization1")}
                />
              </div>
              <div className="col">
                <input
                  type="text"
                  id="organization"
                  className="form-control"
                  defaultValue={organization2}
                  required
                  {...register("organization2")}
                />
              </div>
            </div>
          </section>
          <section className="col-12">
            <div className="row gx-3 gy-0">
              <label htmlFor="phone" className="col-sm-3 form-label">
                Phone number
              </label>
              <div className="col-sm-9">
                <input
                  type="tel"
                  id="phone"
                  className="form-control"
                  defaultValue={phone}
                  required
                  {...phoneValidation}
                  {...register("phone")}
                />
              </div>
            </div>
          </section>
          <section className="col-12">
            <div className="row gx-3 gy-0">
              <label htmlFor="email" className="col-sm-3 form-label">
                Email
              </label>
              <div className="col-sm-9">
                <input
                  type="email"
                  id="email"
                  className="form-control"
                  defaultValue={email}
                  required
                  {...register("email")}
                />
              </div>
            </div>
          </section>
          <section className="col-12">
            <div className="row gx-3 gy-0">
              <label htmlFor="website" className="col-sm-3 form-label">
                Official website
              </label>
              <div className="col">
                <input
                  type="url"
                  id="website"
                  className="form-control"
                  defaultValue={website1}
                  required
                  {...register("website1")}
                />
              </div>
              <div className="col">
                <input
                  type="url"
                  id="website"
                  className="form-control"
                  defaultValue={website2}
                  required
                  {...register("website2")}
                />
              </div>
            </div>
          </section>
          <section className="col-12">
            <div className="row gx-3 gy-0">
              <label htmlFor="facebook" className="col-sm-3 form-label">
                Facebook
              </label>
              <div className="col">
                <input
                  type="url"
                  id="facebook"
                  className="form-control"
                  defaultValue={facebook1}
                  required
                  {...register("facebook1")}
                />
              </div>
              <div className="col">
                <input
                  type="url"
                  id="facebook"
                  className="form-control"
                  defaultValue={facebook2}
                  required
                  {...register("facebook2")}
                />
              </div>
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
      </Card>
    </div>
  );
};

interface CoverImageCardProps {
  defaultValue: string;
}

const CoverImageCard: React.FC<CoverImageCardProps> = ({ defaultValue }) => {
  const {
    register,
    setValue,
    watch,
    handleSubmit,
    formState: { isSubmitting },
    resetField,
  } = useForm();

  const files = watch("files", []);
  const image = watch("cover_image", defaultValue);

  useEffect(() => {
    register("files");
    register("cover_image");
    setValue("cover_image", defaultValue);
  }, []);

  const addImage = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (image || files.length > 0) {
      alert("You must have only one cover image!");
      e.target.value = "";
      return;
    }

    const file = e.target.files![0];
    const filename = "/static/media/about/" + file.name;

    setValue("files", [file]);
    setValue("cover_image", filename);

    e.target.value = "";
  };

  const onSubmit: SubmitHandler<FieldValues> = async data => {
    if (data.files) {
      const formData = new FormData();
      formData.append("files[]", data.files[0]);

      if (data.files.length !== 0) {
        await fetch("/api/uploadImages/about", {
          method: "POST",
          body: formData,
        }).then(response => {
          if (response.status === 413) {
            alert("Files size should be less than 15MB");
            throw new Error();
          }
        });
      }
    }

    const { cover_image } = data;

    await fetch("/api/updateCoverImage", {
      method: "PUT",
      body: JSON.stringify({ path: cover_image }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    resetField("files");
  };

  return (
    <div className="col-xl-6">
      <Card title="Cover">
        <form id="cover-form" className="row g-3" onSubmit={handleSubmit(onSubmit)}>
          <section className="col-12">
            <div className="d-flex gap-3">
              <label htmlFor="cover-image" style={{ cursor: "pointer" }}>
                Image
                <input
                  type="file"
                  className="hidden-input"
                  id="cover-image"
                  name="image"
                  accept="image/*"
                  required={!image}
                  onChange={addImage}
                />
              </label>
              <ul className="img-container">
                {image && (
                  <li className="highlight-onhover">
                    <a
                      href={files.length === 0 ? image : undefined}
                      target="_blank"
                      className="group"
                    >
                      {files.length === 0 ? <IoImageOutline /> : <IoCloudUploadOutline />}
                      {getFilename(image)}
                    </a>
                    <button
                      type="button"
                      className="btn btn-icon remove-img-btn"
                      onClick={() => {
                        setValue("files", []);
                        setValue("cover_image", "");
                      }}
                    >
                      <IoCloseOutline />
                    </button>
                  </li>
                )}
              </ul>
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
      </Card>
    </div>
  );
};
