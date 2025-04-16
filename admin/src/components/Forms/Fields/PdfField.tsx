import { InputHTMLAttributes } from "react";
import { UseFormRegister } from "react-hook-form";

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  register: UseFormRegister<any>;
  label: string;
}

export const PdfField: React.FC<Props> = ({ register, label, ...inputProps }) => {
  return (
    <div className="row gx-3 gy-0">
      <label htmlFor="pdfFile" className="col-auto col-form-label">
        {label}
      </label>
      <div className="col">
        <input
          className="form-control"
          type="file"
          multiple={false}
          accept="application/pdf"
          {...register("pdfFile")}
          {...inputProps}
        />
      </div>
    </div>
  );
};
