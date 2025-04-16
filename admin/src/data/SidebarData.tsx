import { ReactElement } from "react";
import { BsTree } from "react-icons/bs";
import {
  IoBedOutline,
  IoBookOutline,
  IoBookmarksOutline,
  IoBusinessOutline,
  IoCalendarOutline,
  IoFitnessOutline,
  IoHammer,
  IoPeople,
  IoPeopleOutline,
  IoRestaurantOutline,
  IoSpeedometerOutline,
  IoTrendingUpOutline,
  IoWalkOutline,
} from "react-icons/io5";

type SidebarItem = {
  name: string;
  path: string;
  icon: ReactElement;
};

export const SidebarData: Array<SidebarItem> = [
  {
    name: "Dashboard",
    path: "/",
    icon: <IoSpeedometerOutline />,
  },
  {
    name: "Tags",
    path: "/tags",
    icon: <IoBookmarksOutline />,
  },
  {
    name: "Sights",
    path: "/sight",
    icon: <IoBusinessOutline />,
  },
  {
    name: "Tours",
    path: "/tour",
    icon: <IoWalkOutline />,
  },
  {
    name: "Restaurants",
    path: "/restaurant",
    icon: <IoRestaurantOutline />,
  },
  {
    name: "Accommodation",
    path: "/hotel",
    icon: <IoBedOutline />,
  },
  {
    name: "Fabricat în Brăila",
    path: "/madeinbraila",
    icon: <IoHammer />,
  },
  {
    name: "Personalities",
    path: "/personalities",
    icon: <IoPeople />,
  },
  {
    name: "Fitness & Wellness",
    path: "/fitness",
    icon: <IoFitnessOutline />,
  },
  {
    name: "Park",
    path: "/park",
    icon: <BsTree />,
  },
  {
    name: "Events",
    path: "/event",
    icon: <IoCalendarOutline />,
  },
  {
    name: "Trending",
    path: "/trending",
    icon: <IoTrendingUpOutline />,
  },
  {
    name: "About",
    path: "/about",
    icon: <IoBookOutline />,
  },
  {
    name: "Users",
    path: "/users",
    icon: <IoPeopleOutline />,
  },
];
