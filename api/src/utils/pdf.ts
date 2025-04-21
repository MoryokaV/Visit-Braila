import { Request, Response } from "express";
import fs from "fs";
import path from "path";

export const uploadPDF = async (req: Request, res: Response) => {
  res.status(200).send("PDF uploaded successfully");
};

export const deletePDF = (filepath: string): void => {
  try {
    fs.unlinkSync(path.join(__dirname, "..", "..", filepath));
  } catch (_) {
    //pass
  }
};
