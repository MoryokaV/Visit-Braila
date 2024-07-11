import React from "react";
import ReactDOM from "react-dom/client";
import "bootstrap/dist/css/bootstrap.min.css";
import * as bootstrap from "bootstrap";
import "./assets/css/styles.css";
import { RouterProvider, createBrowserRouter } from "react-router-dom";
import App from "./App.tsx";
import ErrorPage from "./pages/404.tsx";
import Login from "./pages/Login.tsx";
import { AuthProvider } from "./hooks/useAuth.tsx";
import { ProtectedRoute } from "./components/ProtectedRoute.tsx";

window.bootstrap = bootstrap;

const router = createBrowserRouter(
  [
    {
      element: <AuthProvider />,
      errorElement: <ErrorPage />,
      children: [
        {
          path: "/",
          element: (
            <ProtectedRoute>
              <App />
            </ProtectedRoute>
          ),
          // children: [
          //   {
          //     index: true,
          //     element: <Dashboard />,
          //   },
          //   {
          //     path: "tags",
          //     element: <TagsPage />,
          //   },
          //   {
          //     path: "sight",
          //     element: <SightPage />,
          //   },
          //   {
          //     path: "tour",
          //     element: <TourPage />,
          //   },
          //   {
          //     path: "restaurant",
          //     element: <RestaurantPage />,
          //   },
          //   {
          //     path: "hotel",
          //     element: <HotelPage />,
          //   },
          //   {
          //     path: "event",
          //     element: <EventPage />,
          //   },
          //   {
          //     path: "trending",
          //     element: <TrendingPage />,
          //   },
          //   {
          //     path: "about",
          //     element: <AboutPage />,
          //   },
          //   {
          //     path: "users",
          //     element: <UsersPage />,
          //   },
          // ],
        },
        {
          path: "/login",
          element: <Login />,
        },
      ],
    },
  ],
  { basename: "/admin" },
);

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>,
);
