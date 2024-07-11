import React, { useEffect, useState } from "react";
import { FieldValues, SubmitHandler, useForm } from "react-hook-form";
import ReactQuill from "react-quill";
import { useAuth } from "../hooks/useAuth";
import { LoadingSpinner } from "../components/LoadingSpinner";
import { About } from "../models/AboutModel";
import { IoCloseOutline, IoCloudUploadOutline, IoImageOutline } from "react-icons/io5";
import { getFilename } from "../utils/images";
import Card from "../components/Card";

export default function AboutPage() {
  const { user } = useAuth();
  const [isLoading, setLoading] = useState(true);
  const [about, setAbout] = useState<About>();

  useEffect(() => {
    fetch("/api/fetchAboutData?city_id=" + user?.city_id)
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
              <HelpCard heading1={about!.heading1} paragraph1={about!.paragraph1} />
              <ContanctCard
                organization={about!.organization}
                phone={about!.phone}
                email={about!.email}
                website={about!.website}
                facebook={about!.facebook}
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
  heading1: string;
  paragraph1: string;
}

const HelpCard: React.FC<HelpCardProps> = ({ heading1, paragraph1 }) => {
  const theme = "snow";
  const placeholder = "Type something here...";

  const {
    register,
    setValue,
    handleSubmit,
    formState: { isSubmitting },
  } = useForm();

  useEffect(() => {
    register("description");
    setValue("description", paragraph1);
  }, [register, setValue]);

  const onEditorStateChanged = (editorState: string) => {
    setValue("description", editorState);
  };

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
              Who are you?
            </label>
            <input
              className="form-control"
              id="headin1"
              defaultValue={heading1}
              required
              {...register("heading1")}
            />
          </section>
          <section className="col-12">
            <label className="form-label">About you</label>

            <ReactQuill
              defaultValue={paragraph1}
              theme={theme}
              placeholder={placeholder}
              onChange={onEditorStateChanged}
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
  organization: string;
  phone: string;
  email: string;
  website: string;
  facebook: string;
}

const ContanctCard: React.FC<ContanctCardProps> = ({
  organization,
  phone,
  email,
  website,
  facebook,
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
              <div className="col-sm-9">
                <input
                  type="text"
                  id="organization"
                  className="form-control"
                  defaultValue={organization}
                  required
                  {...register("organization")}
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
              <div className="col-sm-9">
                <input
                  type="url"
                  id="website"
                  className="form-control"
                  defaultValue={website}
                  required
                  {...register("website")}
                />
              </div>
            </div>
          </section>
          <section className="col-12">
            <div className="row gx-3 gy-0">
              <label htmlFor="facebook" className="col-sm-3 form-label">
                Facebook
              </label>
              <div className="col-sm-9">
                <input
                  type="url"
                  id="facebook"
                  className="form-control"
                  defaultValue={facebook}
                  required
                  {...register("facebook")}
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
  const { user } = useAuth();

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
    const filename = "/static/media/about/" + user?.city_id + "/" + file.name;

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
