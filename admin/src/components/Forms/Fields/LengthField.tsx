import { UseFormRegister } from "react-hook-form";

interface Props {
  register: UseFormRegister<any>;
  defaultValue?: number;
}

export const LengthField: React.FC<Props> = ({ register, defaultValue = 0 }) => {
  return (
    <section className="col-12 d-flex gap-3 align-items-center">
      <label htmlFor="length">Length</label>
      <input
        id="length"
        className="form-control"
        type="number"
        min="0"
        step="0.01"
        required
        {...register("length", { valueAsNumber: true })}
        defaultValue={defaultValue}
      />
      <span className="text-muted">km</span>
    </section>
  );
};
