import "react-quill/dist/quill.snow.css";
import { DescriptionField } from "./Fields/DescriptionField";
import {
  SubmitHandler,
  UseFormGetValues,
  UseFormHandleSubmit,
  UseFormRegister,
  UseFormSetValue,
} from "react-hook-form";
import { InputField } from "./Fields/InputField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { ImagesField } from "./Fields/ImagesField";
import { createImagesFormData } from "../../utils/images";
import { useState } from "react";
import { DateField } from "./Fields/DateField";
import { FormType } from "../../models/FormType";
import { Event } from "../../models/EventModel";
import { convert2LocalDate, getMinEndDate, isValidDate } from "../../utils/dates";

type EventFormType = { notify: boolean } & FormType<Event>;

interface Props {
  register: UseFormRegister<any>;
  handleSubmit: UseFormHandleSubmit<EventFormType, undefined>;
  setValue: UseFormSetValue<any>;
  getValues: UseFormGetValues<any>;
  resetForm: () => void;
  isSubmitting: boolean;
  images: Array<string>;
  files: File[];
  description: string;
}

export const InsertEventForm: React.FC<Props> = ({
  register,
  handleSubmit,
  resetForm,
  setValue,
  getValues,
  isSubmitting,
  images,
  files,
  description,
}) => {
  const [multipleDays, setMultipleDays] = useState(false);

  const onSubmit: SubmitHandler<EventFormType> = async data => {
    const formData = new FormData();
    const { files, notify, ...event } = data;

    createImagesFormData(formData, files);

    await fetch("/api/uploadImages/events", {
      method: "POST",
      body: formData,
    }).then(response => {
      if (response.status === 413) {
        alert("Files size should be less than 15MB");
        throw new Error();
      }
    });

    await fetch("/api/insertEvent", {
      method: "POST",
      body: JSON.stringify({ notify, event }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    resetForm();
  };

  const toggleMultipleDays = (checked: boolean) => {
    if (checked) {
      setMultipleDays(true);
    } else {
      setMultipleDays(false);
      setValue("end_date_time", null);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="row g-3">
      <section className="col-12">
        <InputField
          id="name"
          label="Name"
          register={register}
          type="text"
          required
          maxLength={60}
        />
      </section>
      <section className="col-12">
        <DateField
          id="date_time"
          label="Date & time"
          register={register}
          min={convert2LocalDate(new Date())}
          required
        />
      </section>
      <section className="col-12">
        <div className="form-check">
          <input
            id="multiple-days"
            className="form-check-input"
            type="checkbox"
            name="multiple-days"
            onChange={e => toggleMultipleDays(e.target.checked)}
          />
          <label htmlFor="multiple-days" className="form-check-label">
            Multiple days
          </label>
        </div>
      </section>
      {multipleDays && (
        <section className="col-12">
          <DateField
            id="end_date_time"
            label="End date & time"
            register={register}
            min={
              getValues("date_time")
                ? isValidDate(getValues("date_time"))
                  ? getMinEndDate(getValues("date_time"))
                  : undefined
                : undefined
            }
            required
          />
        </section>
      )}
      <section className="col-12">
        <label className="form-label">Description</label>
        <DescriptionField register={register} setValue={setValue} value={description} />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        collection="events"
        setValue={setValue}
      />
      <section className="col-12">
        <PrimaryImageField register={register} max={files && files.length} />
      </section>
      <section className="col-12">
        <div className="form-check">
          <input
            id="notify"
            className="form-check-input"
            type="checkbox"
            {...register("notify")}
          />
          <label htmlFor="notify" className="form-check-label">
            Send push notification now
          </label>
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
  );
};
