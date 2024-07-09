import { Request, Response, Router } from "express";
import path from "path";
import * as LoginController from "../controllers/loginController";

const router: Router = Router();

const templatesDir = path.join(__dirname, "..", "..", "templates");

// router.get("/master", requiresMasterAuth, (_, res: Response) => {
//   return res.sendFile(path.join(templatesDir, "master.html"));
// });

// router.get("/login", (_, res: Response) => {
//   return res.sendFile(path.join(templatesDir, "login.html"));
// });

router.post("/login", LoginController.login);

router.post("/logout", LoginController.logout);

router.get("/user", (req: Request, res: Response) => {
  if (req.session) {
    return res.status(200).json({
      fullname: req.session.fullname,
      username: req.session.username,
    });
  } else {
    return res.status(403).end();
  }
});

export default router;
