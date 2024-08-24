import { SubmitHandler, useForm } from "react-hook-form";
import { InputField } from "./Fields/InputField";
import { createImagesFormData, getImagesToDelete } from "../../utils/images";
import { DescriptionField } from "./Fields/DescriptionField";
import { ImagesField } from "./Fields/ImagesField";
import { PrimaryImageField } from "./Fields/PrimaryImageField";
import { Event } from "../../models/EventModel";
import { DateField } from "./Fields/DateField";
import { useState } from "react";
import { FormType } from "../../models/FormType";
import { convert2LocalDate, getMinEndDate } from "../../utils/dates";

interface Props {
  event: Event;
  updateTable: (updatedEvent: Event) => void;
  closeModal: () => void;
}

export const EditEventForm: React.FC<Props> = ({ event, updateTable, closeModal }) => {
  const [multipleDays, setMultipleDays] = useState(event.end_date_time != null);
  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
    reset,
    setValue,
    watch,
  } = useForm<FormType<Event>>();

  const files = watch("files", []);
  const images = watch("images", [...event.images]);
  const date_time = watch("date_time", event.date_time);

  const onSubmit: SubmitHandler<FormType<Event>> = async data => {
    const formData = new FormData();
    const { files, ...updatedEvent } = data;

    createImagesFormData(formData, files);

    if (files.length !== 0) {
      await fetch("/api/uploadImages/events", {
        method: "POST",
        body: formData,
      }).then(response => {
        if (response.status === 413) {
          alert("Files size should be less than 15MB");
          throw new Error();
        }
      });
    }

    const images_to_delete = getImagesToDelete(event.images, updatedEvent.images);

    await fetch("/api/editEvent", {
      method: "PUT",
      body: JSON.stringify({
        images_to_delete,
        _id: event._id,
        event: updatedEvent,
      }),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    updatedEvent._id = event._id;
    updateTable(updatedEvent);

    closeModal();

    reset();
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
          defaultValue={event.name}
        />
      </section>
      <section className="col-12">
        <DateField
          id="date_time"
          label="Date & time"
          register={register}
          required
          defaultDate={event.date_time}
          min={convert2LocalDate(new Date())}
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
            checked={multipleDays}
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
            required
            defaultDate={event.end_date_time ? event.end_date_time : undefined}
            min={getMinEndDate(date_time)}
          />
        </section>
      )}
      <section className="col-12">
        <label className="form-label">Description</label>
        <DescriptionField
          register={register}
          setValue={setValue}
          defaultValue={event.description}
        />
      </section>
      <ImagesField
        register={register}
        images={images}
        files={files}
        setValue={setValue}
        collection="events"
      />
      <section className="col-12">
        <PrimaryImageField
          register={register}
          max={images && images.length}
          defaultValue={event.primary_image}
        />
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
  );
};
