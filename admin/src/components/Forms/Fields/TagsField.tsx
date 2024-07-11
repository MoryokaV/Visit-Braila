import { useEffect, useRef, useState } from "react";
import { UseFormRegister, UseFormSetValue } from "react-hook-form";
import { Tag } from "../../../models/TagModel";
import { useAuth } from "../../../hooks/useAuth";

interface Props {
  register: UseFormRegister<any>;
  setValue: UseFormSetValue<any>;
  collection: string;
  activeTags?: Array<string>;
}

type ButtonActionType = "Add" | "Remove";
type ButtonHandlerType = (() => React.MouseEventHandler) | undefined;

export const TagsField: React.FC<Props> = ({
  register,
  setValue,
  collection,
  activeTags = [],
}) => {
  const { user } = useAuth();
  const selectRef = useRef<HTMLSelectElement>(null);

  const [tags, setTags] = useState<Array<Tag>>([]);

  const [buttonAction, setButtonAction] = useState<ButtonActionType>("Add");
  const [buttonHandler, setButtonHandler] = useState<ButtonHandlerType>(undefined);

  useEffect(() => {
    fetch(`/api/fetchTags/${collection}?city_id=${user?.city_id}`)
      .then(response => response.json())
      .then(data => setTags(data));

    register("tags");
    setValue("tags", activeTags);
  }, []);

  const selectChangeHandler = (e: React.ChangeEvent<HTMLSelectElement>) => {
    if (!activeTags.includes(e.currentTarget.value)) {
      setButtonAction("Add");
      setButtonHandler(() => appendTag);
    } else {
      setButtonAction("Remove");
      setButtonHandler(() => removeTag);
    }
  };

  const appendTag = () => {
    if (activeTags.length === 3) {
      alert("You cannot use more than 3 tags!");
      return;
    }

    activeTags.push(selectRef.current!.value);
    setValue("tags", activeTags);

    setButtonAction("Add");
    setButtonHandler(undefined);
    selectRef.current!.value = "-";
  };

  const removeTag = () => {
    const index = activeTags.indexOf(selectRef.current!.value);
    activeTags.splice(index, 1);
    setValue("tags", activeTags);

    setButtonAction("Add");
    setButtonHandler(undefined);
    selectRef.current!.value = "-";
  };

  return (
    <section className="col-12 d-flex flex-wrap gap-3">
      <label htmlFor="tags" className="col-form-label">
        Tags
      </label>
      <div className="col-sm-3">
        <select
          ref={selectRef}
          id="tags"
          name="tags"
          className="form-select"
          defaultValue="-"
          onChange={selectChangeHandler}
        >
          <option disabled hidden>
            -
          </option>
          {tags.map((tag, index) => {
            return (
              <option key={index} value={tag.name}>
                {tag.name}
              </option>
            );
          })}
        </select>
      </div>
      <a
        role="button"
        className={`btn btn-text text-primary ${
          buttonAction === "Remove" && "text-danger"
        }`}
        onClick={buttonHandler}
      >
        {buttonAction}
      </a>
      <div className="d-flex align-items-center flex-wrap gap-2">
        {activeTags.map((tag, index) => {
          return (
            <span key={index} className="badge bg-primary">
              {tag}
            </span>
          );
        })}
      </div>
    </section>
  );
};
