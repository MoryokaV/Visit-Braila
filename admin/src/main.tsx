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
import Dashboard from "./pages/Dashboard.tsx";
import TagsPage from "./pages/Tags.tsx";
import SightPage from "./pages/Sight.tsx";
import TourPage from "./pages/Tour.tsx";
import RestaurantPage from "./pages/Restaurant.tsx";
import HotelPage from "./pages/Hotel.tsx";
import EventPage from "./pages/Event.tsx";
import TrendingPage from "./pages/Trending.tsx";
import AboutPage from "./pages/About.tsx";
import UsersPage from "./pages/Users.tsx";
import ParkPage from "./pages/Park.tsx";
import FitnessPage from "./pages/Fitness.tsx";
import MadeInBrailaPage from "./pages/MadeInBraila.tsx";
import PersonalityPage from "./pages/Personality.tsx";

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
              path: "madeinbraila",
              element: <MadeInBrailaPage />,
            },
            {
              path: "personalities",
              element: <PersonalityPage />,
            },
            {
              path: "fitness",
              element: <FitnessPage />,
            },
            {
              path: "park",
              element: <ParkPage />,
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
