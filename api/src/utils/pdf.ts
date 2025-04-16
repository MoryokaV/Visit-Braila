import { Request, Response } from "express";
import fs from "fs";

export const uploadPDF = async (req: Request, res: Response) => {
  res.status(200).send("PDF uploaded successfully");
};

export const deletePDF = (path: string): void => {
  try {
    fs.unlinkSync("." + path);
  } catch (_) {
    //pass
  }
};
