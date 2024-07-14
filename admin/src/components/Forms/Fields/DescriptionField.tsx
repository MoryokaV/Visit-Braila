import { useEffect } from "react";
import { UseFormRegister, UseFormSetValue } from "react-hook-form";
import ReactQuill from "react-quill";

type Props =
  | {
      register: UseFormRegister<any>;
      setValue: UseFormSetValue<any>;
      value?: string;
      defaultValue?: never;
    }
  | {
      register: UseFormRegister<any>;
      setValue: UseFormSetValue<any>;
      value?: never;
      defaultValue?: string;
    };

export const DescriptionField: React.FC<Props> = ({
  register,
  setValue,
  value,
  defaultValue,
}) => {
  const theme = "snow";
  const placeholder = "Type something here...";

  useEffect(() => {
    register("description");

    if (value !== null) {
      setValue("description", value);
    }

    if (defaultValue !== null) {
      setValue("description", defaultValue);
    }
  }, [register, setValue]);

  const onEditorStateChanged = (editorState: string) => {
    setValue("description", editorState);
  };

  return defaultValue === null ? (
    <ReactQuill
      value={value}
      theme={theme}
      placeholder={placeholder}
      onChange={onEditorStateChanged}
    />
  ) : (
    <ReactQuill
      defaultValue={defaultValue}
      theme={theme}
      placeholder={placeholder}
      onChange={onEditorStateChanged}
    />
  );
};
