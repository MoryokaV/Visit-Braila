import React from "react";
import ReactDOM from "react-dom/client";
import "bootstrap/dist/css/bootstrap.min.css";
import * as bootstrap from "bootstrap";
import "./assets/css/styles.css";
import { RouterProvider, createBrowserRouter } from "react-router-dom";
import Dashboard from "./pages/Dashboard";
import App from "./App";
import ErrorPage from "./pages/404";
import Login from "./pages/Login";
import { AuthProvider } from "./hooks/useAuth";
import { ProtectedRoute } from "./components/ProtectedRoute";
import SightPage from "./pages/Sight";
import TourPage from "./pages/Tour";
import RestaurantPage from "./pages/Restaurant";
import HotelPage from "./pages/Hotel";
import TagsPage from "./pages/Tags";
import EventPage from "./pages/Event";
import TrendingPage from "./pages/Trending";
import AboutPage from "./pages/About";
import MasterPage from "./pages/Master";
import UsersPage from "./pages/Users";

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
          children: [
            {
              index: true,
              element: <Dashboard />,
            },
            {
              path: "tags",
              element: <TagsPage />,
            },
            {
              path: "sight",
              element: <SightPage />,
            },
            {
              path: "tour",
              element: <TourPage />,
            },
            {
              path: "restaurant",
              element: <RestaurantPage />,
            },
            {
              path: "hotel",
              element: <HotelPage />,
            },
            {
              path: "event",
              element: <EventPage />,
            },
            {
              path: "trending",
              element: <TrendingPage />,
            },
            {
              path: "about",
              element: <AboutPage />,
            },
            {
              path: "users",
              element: <UsersPage />,
            },
          ],
        },
        {
          path: "master",
          element: <MasterPage />,
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
