import { IoMenuOutline, IoLogOutOutline } from "react-icons/io5";
import styles from "../assets/css/Navbar.module.css";
import { useAuth } from "../hooks/useAuth";

interface Props {
  onMenuBtnClick: () => void;
}

const Navbar: React.FC<Props> = ({ onMenuBtnClick }) => {
  const { logout } = useAuth();

  const logoutBtnHandler = () => {
    fetch("/api/logout", {
      method: "POST",
    }).then(() => {
      logout();
    });
  };

  return (
    <header className={styles.topbar}>
      <div className="group">
        <button
          className={`btn-icon ${styles.btnHeader} ${styles.btnMenu}`}
          onClick={onMenuBtnClick}
        >
          <IoMenuOutline size="1.5rem" />
        </button>
        <h1 className={styles.title}>Visit Brăila</h1>
      </div>
      <button
        onClick={logoutBtnHandler}
        role="button"
        className={`btn-icon ${styles.btnHeader}`}
      >
        <IoLogOutOutline size="1.5rem" />
      </button>
    </header>
  );
};

export default Navbar;
