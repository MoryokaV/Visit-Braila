import { Request, Response } from "express";
import UAParser from "ua-parser-js";

const GOOGLE_PLAY_URL =
  "https://play.google.com/store/apps/details?id=com.vmasoftware.visit_braila";
const APP_STORE_URL = "https://apps.apple.com/ro/app/visit-br%C4%83ila/id6448944001";

export const appInstallRedirect = (req: Request, res: Response) => {
  const ua = req.get("user-agent");
  const parser = new UAParser(ua);
  const os = parser.getOS().name;

  if (os === "Mac OS" || os === "iOS") {
    return res.redirect(APP_STORE_URL);
  } else {
    return res.redirect(GOOGLE_PLAY_URL);
  }
};
