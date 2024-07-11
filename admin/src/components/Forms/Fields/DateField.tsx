import { InputHTMLAttributes } from "react";
import { UseFormRegister } from "react-hook-form";
import { convert2LocalDate } from "../../../utils/dates";

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  register: UseFormRegister<any>;
  label: string;
  id: string;
  defaultDate?: Date;
}

export const DateField: React.FC<Props> = ({
  register,
  label,
  id,
  defaultDate,
  ...inputProps
}) => {
  return (
    <>
      <label htmlFor={id} className="form-label">
        {label}
      </label>
      <input
        id={id}
        className="form-control"
        type="datetime-local"
        defaultValue={defaultDate && convert2LocalDate(defaultDate)}
        {...register(id, { valueAsDate: true })}
        {...inputProps}
      />
    </>
  );
};
