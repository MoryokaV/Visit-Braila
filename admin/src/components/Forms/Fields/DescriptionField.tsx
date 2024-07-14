import { useEffect } from "react";
import { UseFormRegister, UseFormSetValue } from "react-hook-form";
import ReactQuill from "react-quill";

interface Props {
  register: UseFormRegister<any>;
  setValue: UseFormSetValue<any>;
  value?: string;
  defaultValue?: string;
}

export const DescriptionField: React.FC<Props> = ({
  register,
  setValue,
  value = "",
  defaultValue = "",
}) => {
  const theme = "snow";
  const placeholder = "Type something here...";

  useEffect(() => {
    register("description");
    setValue("description", defaultValue || value);
  }, []);

  const onEditorStateChanged = (editorState: string) => {
    setValue("description", editorState);
  };

  return value !== "" ? (
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
