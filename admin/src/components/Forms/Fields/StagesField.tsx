import { UseFormRegister, UseFormSetValue } from "react-hook-form";
import { IoAddOutline, IoLinkOutline } from "react-icons/io5";
import { Fragment, useEffect, useState } from "react";
import { idValidation } from "../../../data/RegExpData";

interface Props {
  register: UseFormRegister<any>;
  setValue: UseFormSetValue<any>;
  stages?: Array<Stage>;
}

const emptyStage: Stage = {
  text: "",
  sight_link: "",
};

const defaultValue: Array<Stage> = [{ ...emptyStage }, { ...emptyStage }];

const LinkInputElement = ({
  link,
  onChange,
}: {
  link: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}) => {
  return (
    <input
      defaultValue={link}
      type="text"
      size={10}
      className="stage-link form-control text-primary"
      placeholder="Sight id"
      onChange={onChange}
      required
      {...idValidation}
    />
  );
};

export const StagesField: React.FC<Props> = ({
  register,
  setValue,
  stages = defaultValue,
}) => {
  const [links, setLinks] = useState<Array<boolean>>([]);

  useEffect(() => {
    register("stages");
    setValue("stages", stages);
  }, []);

  const addStage = () => {
    stages.push({ ...emptyStage });

    setValue("stages", [...stages]);
  };

  const toggleLink = (index: number) => {
    links[index] = !links[index];
    stages[index].sight_link = "";

    setLinks([...links]);
    setValue("stages", [...stages]);
  };

  const setStageLink = (index: number, newLink: string) => {
    stages[index].sight_link = newLink;

    setValue("stages", [...stages]);
  };

  const setStageTitle = (index: number, newTitle: string) => {
    stages[index].text = newTitle;

    setValue("stages", [...stages]);
  };

  const deleteInputIfEmpty = (
    e: React.KeyboardEvent<HTMLInputElement>,
    index: number,
  ) => {
    if (e.key === "Backspace" && stages.length > 2 && stages[index].text === "") {
      e.preventDefault();
      stages.splice(index, 1);

      links[index] = false;
      setLinks(links);

      setValue("stages", [...stages]);
    }
  };

  return (
    <section className="col-12">
      <label className="form-label">Stages</label>
      <div id="stages" className="stages-container">
        {stages.map((stage, index) => {
          return (
            <Fragment key={index}>
              <div className="stage">
                <input
                  type="text"
                  size={stage.text.length}
                  value={stage.text}
                  className="form-control"
                  maxLength={55}
                  onChange={e => setStageTitle(index, e.currentTarget.value)}
                  onKeyDown={e => deleteInputIfEmpty(e, index)}
                  required
                />
                <IoLinkOutline
                  className={`stage-input-icon ${
                    stage.sight_link !== "" || links[index] ? "active" : ""
                  }`}
                  onClick={() => toggleLink(index)}
                />
              </div>
              {(stage.sight_link !== "" || links[index]) && (
                <LinkInputElement
                  link={stage.sight_link}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                    setStageLink(index, e.currentTarget.value)
                  }
                />
              )}
              {index !== stages.length - 1 && "-"}
            </Fragment>
          );
        })}
        <button
          type="button"
          className="btn btn-icon text-primary"
          id="add-stage"
          onClick={addStage}
        >
          <IoAddOutline />
        </button>
      </div>
    </section>
  );
};
