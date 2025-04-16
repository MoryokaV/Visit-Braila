export type FormType<T> = T & { files: File[] };
export type PdfFormType<T> = T & { files: File[]; pdfFile: File[] };
