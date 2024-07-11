import { useEffect } from "react";
import { UseFormRegister, UseFormSetValue } from "react-hook-form";
import ReactQuill from "react-quill";

interface Props {
  register: UseFormRegister<any>;
  setValue: UseFormSetValue<any>;
  value?: string;
}

export const DescriptionField: React.FC<Props> = ({ register, setValue, value = "" }) => {
  const theme = "snow";
  const placeholder = "Type something here...";

  useEffect(() => {
    register("description");
    setValue("description", value);
  }, [register, setValue]);

  const onEditorStateChanged = (editorState: string) => {
    setValue("description", editorState);
  };

  return (
    <ReactQuill
      value={value}
      theme={theme}
      placeholder={placeholder}
      onChange={onEditorStateChanged}
    />
  );
};
