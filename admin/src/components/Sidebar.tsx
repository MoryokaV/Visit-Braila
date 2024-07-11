import { useEffect, useState } from "react";
import { NavLink } from "react-router-dom";
import { IoPersonCircle } from "react-icons/io5";
import { SidebarData } from "../data/SidebarData";
import styles from "../assets/css/Sidebar.module.css";
import { useAuth } from "../hooks/useAuth";

interface SidebarProps {
  show: boolean;
  sidebarRef: React.RefObject<HTMLElement>;
}

const Sidebar: React.FC<SidebarProps> = ({ show, sidebarRef }) => {
  const { user } = useAuth();

  return (
    <aside
      ref={sidebarRef}
      className={`${show ? `${styles.show}` : ""} ${styles.sidebar}`}
    >
      <header>
        <IoPersonCircle size="2rem" className="col-2" />
        <p className="col mb-0 fw-normal fs-5 text-truncate">{user?.fullname}</p>
      </header>
      <hr />
      <nav>
        {SidebarData.map((item, index) => {
          if (item.path === "/users" && user?.username !== "admin") {
            return;
          }
          return (
            <NavItem path={item.path} icon={item.icon} key={index}>
              {item.name}
            </NavItem>
          );
        })}
      </nav>
      <hr />
      <StorageInfo />
    </aside>
  );
};

interface NavItemProps {
  path: string;
  icon: React.ReactElement;
  children: string;
}

const NavItem: React.FC<NavItemProps> = ({ path, icon, children }) => {
  return (
    <NavLink
      to={path}
      className={({ isActive }) =>
        (isActive ? `${styles.active}` : "") + ` ${styles.navItem} group`
      }
    >
      {icon}
      <p>{children}</p>
    </NavLink>
  );
};

const StorageInfo = () => {
  const [diskUsage, setDiskUsage] = useState({
    used: 0,
    total: 0,
  });

  useEffect(() => {
    fetch("/api/serverStorage")
      .then(response => response.json())
      .then(data => setDiskUsage(data));
  }, []);

  return (
    <section className={styles.storageInfo}>
      <p>
        Server storage: <span>{diskUsage.used} GB</span> of{" "}
        <span>{diskUsage.total} GB</span> Used
      </p>
      <div className={styles.barOutline}>
        <div
          className={styles.barFilled}
          style={{ width: `${(diskUsage.used * 100) / diskUsage.total}%` }}
        ></div>
      </div>
    </section>
  );
};

export default Sidebar;
