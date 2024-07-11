import { InputHTMLAttributes } from "react";
import { UseFormRegister } from "react-hook-form";

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  register: UseFormRegister<any>;
  label: string;
  id: string;
  valueAsNumber?: boolean;
}

export const InputField: React.FC<Props> = ({
  register,
  label,
  id,
  valueAsNumber = false,
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
        {...register(id, { valueAsNumber })}
        {...inputProps}
      />
    </>
  );
};
