import { Response, Request, NextFunction, RequestHandler } from "express";

export const requiresAuth: RequestHandler = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (req.session.logged_in) {
    next();
  } else {
    res.status(401).redirect("/login");
  }
};

export const requiresAdminAuth: RequestHandler = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (req.session.username === "admin") {
    next();
  } else {
    res.status(401).redirect("/login");
  }
};
