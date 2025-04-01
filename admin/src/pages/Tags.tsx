import { SubmitHandler, useForm } from "react-hook-form";
import { useEffect, useState } from "react";
import Card from "../components/Card";
import { Tag } from "../models/TagModel";
import { InputField } from "../components/Forms/Fields/InputField";
import { tagValidation } from "../data/RegExpData";
import { LoadingSpinner } from "../components/LoadingSpinner";
import { IoCloseOutline } from "react-icons/io5";
import TableCard from "../components/TableCard";

export default function TagsPage() {
  const [tags, setTags] = useState<Array<Tag>>([]);
  const [isLoading, setLoading] = useState(true);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
  } = useForm<Tag>();

  useEffect(() => {
    fetchTags();
  }, []);

  const fetchTags = async () => {
    setLoading(true);

    await fetch("/api/fetchTags/all")
      .then(response => response.json())
      .then(data => {
        setTags(data);
        setLoading(false);
      });
  };

  const getDotColor = (used_for: string) => {
    if (used_for === "sights") {
      return "dot-green";
    } else if (used_for === "restaurants") {
      return "dot-purple";
    } else if (used_for === "hotels") {
      return "dot-yellow";
    } else if (used_for === "madeinbraila") {
      return "dot-blue";
    }
  };

  const deleteTag = async (id: string) => {
    await fetch("/api/deleteTag/" + id, { method: "DELETE" });

    setTags(tags.filter(tag => tag._id !== id));
  };

  const onSubmit: SubmitHandler<Tag> = async data => {
    if (
      tags.filter(tag => tag.name === data.name && tag.used_for === data.used_for)
        .length > 0
    ) {
      alert("Tag already exists!");
      return;
    }

    await fetch("/api/insertTag", {
      method: "POST",
      body: JSON.stringify(data),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    fetchTags();

    reset();
  };

  return (
    <div className="d-flex h-100">
      <div className="container-md m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-sm-6 col-lg-4">
            <Card title="Insert tag">
              <form className="row g-3" onSubmit={handleSubmit(onSubmit)}>
                <section className="col-12">
                  <InputField
                    id="name"
                    label="Name"
                    register={register}
                    type="text"
                    required
                    maxLength={30}
                    {...tagValidation}
                  />
                </section>
                <section className="col-12">
                  <label className="form-label">Used for</label>
                  <div>
                    <div className="form-check">
                      <input
                        className="form-check-input"
                        type="radio"
                        id="sights-radio"
                        value="sights"
                        {...register("used_for")}
                        required
                      />
                      <label
                        className="form-check-label dot dot-green"
                        htmlFor="sights-radio"
                      >
                        Sights
                      </label>
                    </div>
                    <div className="form-check">
                      <input
                        className="form-check-input"
                        type="radio"
                        id="restaurants-radio"
                        value="restaurants"
                        {...register("used_for")}
                        required
                      />
                      <label
                        className="form-check-label dot dot-purple"
                        htmlFor="restaurants-radio"
                      >
                        Restaurants
                      </label>
                    </div>
                    <div className="form-check">
                      <input
                        className="form-check-input"
                        type="radio"
                        id="hotels-radio"
                        value="hotels"
                        {...register("used_for")}
                        required
                      />
                      <label
                        className="form-check-label dot dot-yellow"
                        htmlFor="hotels-radio"
                      >
                        Hotels
                      </label>
                    </div>
                    <div className="form-check">
                      <input
                        className="form-check-input"
                        type="radio"
                        id="madeinbraila-radio"
                        value="madeinbraila"
                        {...register("used_for")}
                        required
                      />
                      <label
                        className="form-check-label dot dot-blue"
                        htmlFor="madeinbraila-radio"
                      >
                        Made in Brăila
                      </label>
                    </div>
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
            </Card>
          </div>
          <div className="col-sm-6 col-lg-4">
            <TableCard title="Tags list" records={tags.length}>
              <table>
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Name</th>
                  </tr>
                </thead>
                <tbody>
                  {isLoading ? (
                    <tr>
                      <td colSpan={100} className="my-auto text-center">
                        <LoadingSpinner />
                      </td>
                    </tr>
                  ) : (
                    <>
                      {tags.map((tag, index) => {
                        return (
                          <tr key={index}>
                            <td className="small-cell">{index + 1}</td>
                            <td>
                              <div className="highlight-onhover">
                                <p className={`dot ${getDotColor(tag.used_for)}`}>
                                  {tag.name}
                                </p>
                                <button
                                  type="button"
                                  className="btn btn-icon"
                                  onClick={() => deleteTag(tag._id)}
                                >
                                  <IoCloseOutline />
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })}
                    </>
                  )}
                </tbody>
              </table>
            </TableCard>
          </div>
        </div>
      </div>
    </div>
  );
}
