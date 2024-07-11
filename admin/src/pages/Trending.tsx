import { useEffect, useState } from "react";
import {
  IoAddCircleOutline,
  IoCloseOutline,
  IoCloudUploadOutline,
  IoHeartOutline,
  IoImageOutline,
} from "react-icons/io5";
import { useAuth } from "../hooks/useAuth";
import { Trending } from "../models/TrendingModel";
import { SubmitHandler, useForm } from "react-hook-form";
import { FormType } from "../models/FormType";
import { getFilename } from "../utils/images";
import Sortable from "sortablejs";
import Card from "../components/Card";

type RefItemType = {
  name: string;
  image: string;
};

export default function TrendingPage() {
  const { user } = useAuth();
  const [trendingItems, setTrendingItems] = useState<Array<Trending>>([]);
  const [refItems, setRefItems] = useState<Array<RefItemType>>([]);
  const [showForm, setShowForm] = useState(false);
  const [newItemId, setNewItemId] = useState("");
  const [loadingItems, setLoadingItems] = useState(false);

  useEffect(() => {
    fetchTrending();

    document.addEventListener("click", dismissForm);

    const list = document.querySelector<HTMLElement>(".trending-container")!;

    new Sortable(list, {
      animation: 150,
      easing: "cubic-bezier(0.65, 0, 0.35, 1)",
      delay: 200,
      delayOnTouchOnly: true,
      onEnd: async function (e) {
        setLoadingItems(true);

        let items: Array<string> = [];
        for (
          let i = Math.min(e.oldIndex!, e.newIndex!);
          i <= Math.max(e.oldIndex!, e.newIndex!);
          i++
        ) {
          items.push(document.querySelectorAll(".trending-container article")![i].id);
        }

        await fetch("/api/updateTrendingItemIndex", {
          method: "PUT",
          body: JSON.stringify({
            oldIndex: e.oldIndex,
            newIndex: e.newIndex,
            items: items,
          }),
          headers: { "Content-Type": "application/json; charset=UTF-8" },
        });

        setTimeout(() => {
          setLoadingItems(false);
        }, 250);
      },
    });

    return () => {
      document.removeEventListener("click", dismissForm);
    };
  }, []);

  const dismissForm = (e: MouseEvent) => {
    if (
      !document.querySelector("#trending-form")!.contains(e.target as Node) &&
      !document.querySelector("#add-item")!.contains(e.target as Node)
    ) {
      setShowForm(false);
    }
  };

  const fetchTrending = async () => {
    const trending = await fetch(`/api/fetchTrendingItems?city_id=${user?.city_id}`).then(
      response => response.json(),
    );

    await Promise.all(trending.map((item: Trending) => getNameImageItem(item))).then(
      data => setRefItems(data),
    );

    setTrendingItems(trending);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const newItem = {
      item_id: newItemId,
      type: "",
      index: trendingItems.length,
    };

    if (trendingItems.filter(i => i.item_id === newItem.item_id).length > 0) {
      alert("Item already present in list");
      setNewItemId("");

      return;
    }

    const sight = await fetch("/api/findSight/" + newItem.item_id)
      .then(response => response.json())
      .catch(() => {});
    const restaurant = await fetch("/api/findRestaurant/" + newItem.item_id)
      .then(response => response.json())
      .catch(() => {});
    const hotel = await fetch("/api/findHotel/" + newItem.item_id)
      .then(response => response.json())
      .catch(() => {});

    if (sight !== undefined) {
      newItem.type = "sight";
    } else if (restaurant !== undefined) {
      newItem.type = "restaurant";
    } else if (hotel !== undefined) {
      newItem.type = "hotel";
    } else {
      alert("ERROR: Not a valid sight/restaurant/hotel id!");
    }

    if (newItem.type !== "") {
      fetch("/api/insertTrendingItem", {
        method: "POST",
        body: JSON.stringify(newItem),
        headers: {
          "Content-Type": "application/json",
        },
      });
    }

    await fetchTrending();
    setNewItemId("");
    setShowForm(false);
  };

  const getNameImageItem = async (item: Trending): Promise<RefItemType> => {
    if (item.type === "sight") {
      const response = await fetch("/api/findSight/" + item.item_id);
      const sight = await response.json();
      const { name, images, primary_image } = sight;

      return { name, image: images[primary_image - 1] };
    } else if (item.type === "restaurant") {
      const response = await fetch("/api/findRestaurant/" + item.item_id);
      const restaurant = await response.json();
      const { name, images, primary_image } = restaurant;

      return { name, image: images[primary_image - 1] };
    } else if (item.type === "hotel") {
      const response = await fetch("/api/findHotel/" + item.item_id);
      const hotel = await response.json();
      const { name, images, primary_image } = hotel;

      return { name, image: images[primary_image - 1] };
    }

    return { name: "", image: "" };
  };

  const removeItem = async (id: string, index: number) => {
    await fetch("/api/deleteTrendingItem?_id=" + id + "&index=" + index, {
      method: "DELETE",
    });

    await fetchTrending();
  };

  return (
    <div className="d-flex h-100">
      <div className="container-md m-auto py-3 d-flex flex-column align-items-center">
        <h2 className="tab-title">Trending items</h2>

        <div
          className={`d-flex align-items-center trending-container ${
            trendingItems.length === 0 && "empty"
          }`}
        >
          {trendingItems.length > 0 ? (
            <>
              {trendingItems.map((item, index) => {
                const { name, image } = refItems[index];
                return (
                  <article className="trending-item" key={index} id={item._id}>
                    <img src={image} alt={name} />
                    <footer className={`${loadingItems && "loading"}`}>
                      <p>{name}</p>
                      <div className="loading-spinner"></div>
                      <IoHeartOutline className="icon" />
                      <button
                        className="btn btn-icon remove-item icon"
                        onClick={() => removeItem(item._id, item.index)}
                      >
                        <IoCloseOutline />
                      </button>
                    </footer>
                  </article>
                );
              })}
            </>
          ) : (
            <p>No items in list</p>
          )}
        </div>

        <button
          className={`${
            showForm && "d-none"
          } btn btn-text text-primary d-flex align-items-center gap-2`}
          onClick={() => setShowForm(!showForm)}
          id="add-item"
        >
          <IoAddCircleOutline />
          Add
        </button>

        <form
          id="trending-form"
          onSubmit={handleSubmit}
          className={`${
            showForm ? "" : "d-none"
          } row row-cols-auto g-2 align-items-center justify-content-center w-100`}
        >
          <section className="col">
            <input
              type="text"
              id="item-id"
              className="form-control"
              name="item-id"
              placeholder="id"
              value={newItemId}
              onChange={e => setNewItemId(e.target.value)}
              required
            />
          </section>
          <section className="col">
            <button type="submit" className="btn btn-primary">
              Add
            </button>
          </section>
        </form>

        <div className="col-10 col-xl-6 mt-4">
          <Card title="Home screen header">
            <UpdateHeaderForm city_id={user?.city_id!} city_name={user?.city_name!} />
          </Card>
        </div>
      </div>
    </div>
  );
}

type AboutHeader = {
  header_title: string;
  header_image: string;
};

const UpdateHeaderForm = ({
  city_id,
  city_name,
}: {
  city_id: string;
  city_name: string;
}) => {
  const [loading, setLoading] = useState(true);
  const [header, setHeader] = useState<AboutHeader>({
    header_title: "",
    header_image: "",
  });

  const {
    register,
    formState: { isSubmitting },
    handleSubmit,
    setValue,
    watch,
    resetField,
  } = useForm<FormType<AboutHeader>>();

  const files = watch("files", []);
  const title = watch("header_title", header.header_title);
  const image = watch("header_image", header.header_image);

  useEffect(() => {
    fetchHeaderData();

    register("files");
    register("header_image");
  }, []);

  const fetchHeaderData = async () => {
    const data = await fetch("/api/fetchAboutData?city_id=" + city_id).then(response =>
      response.json(),
    );

    setHeader(data);
    setLoading(false);
    setValue("header_image", data.header_image);
  };

  const addImage = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (image || files.length > 0) {
      alert("You must have only one header image!");
      e.target.value = "";
      return;
    }

    const file = e.target.files![0];
    const filename = "/static/media/about/" + city_id + "/" + file.name;

    setValue("files", [file]);
    setValue("header_image", filename);

    e.target.value = "";
  };

  const onSubmit: SubmitHandler<FormType<AboutHeader>> = async data => {
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

    const { files, ...updatedHeader } = data;

    await fetch("/api/updateHeader", {
      method: "PUT",
      body: JSON.stringify(updatedHeader),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    resetField("files");
    setHeader(updatedHeader);
  };

  return (
    !loading && (
      <form className="row g-3" onSubmit={handleSubmit(onSubmit)}>
        <section className="col-12">
          <label htmlFor="header-title" className="form-label">
            Title
            <span className="form-text text-sm">(start with lowercase)</span>
          </label>
          <input
            className="form-control"
            id="header-title"
            required
            defaultValue={header.header_title}
            {...register("header_title")}
          />
          <div className="form-text">{`Preview ${city_name}: ${title}`}</div>
        </section>
        <section className="col-12">
          <div className="d-flex gap-3">
            <label htmlFor="header-image" style={{ cursor: "pointer" }}>
              Image
              <input
                type="file"
                className="hidden-input"
                id="header-image"
                accept="image/*"
                required={!image}
                onChange={addImage}
              />
            </label>
            <ul className="img-container">
              {image && (
                <li className="highlight-onhover">
                  <a
                    href={files.length === 0 ? header.header_image : undefined}
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
                      setValue("header_image", "");
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
    )
  );
};
