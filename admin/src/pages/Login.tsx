import { IoEyeOffOutline, IoEyeOutline } from "react-icons/io5";
import styles from "../assets/css/Login.module.css";
import icon from "../assets/images/icon.png";
import { useState } from "react";
import { useAuth } from "../hooks/useAuth";

export default function Login() {
  const [showPassword, setShowPassword] = useState(false);
  const [loginDetails, setLoginDetails] = useState({
    username: "",
    password: "",
  });

  const { login } = useAuth();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    await fetch("/api/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(loginDetails),
    }).then(async response => {
      if (response.status === 200) {
        const data = await response.json();
        login(data.user, data.url);
      } else {
        const error = await response.text();
        alert(error);
      }
    });
  };

  const toggleShowPassword = () => setShowPassword(!showPassword);

  return (
    <div className={styles.background}>
      <main className={styles.content}>
        <div className="row g-0">
          <div className="col-sm-6">
            <div className={styles.sideImg}></div>
          </div>
          <div className="col-sm-6">
            <form className={styles.formLogin} onSubmit={handleSubmit}>
              <img className="mb-2 img-fluid" src={icon} width="128" height="128" />
              <h2 className="mb-4 fw-medium">CITY BREAK</h2>
              <section className="form-floating">
                <input
                  type="text"
                  className="form-control"
                  spellCheck="false"
                  autoCorrect="off"
                  autoCapitalize="off"
                  autoComplete="username"
                  id="username"
                  name="username"
                  placeholder="user"
                  required
                  style={{
                    marginBottom: "-1px",
                    borderBottomLeftRadius: "0",
                    borderBottomRightRadius: "0",
                  }}
                  onChange={e =>
                    setLoginDetails({ ...loginDetails, username: e.target.value })
                  }
                />
                <label className="floatingInput">Username</label>
              </section>

              <section className="form-floating">
                <input
                  type={showPassword ? "text" : "password"}
                  className="form-control"
                  spellCheck="false"
                  autoCorrect="off"
                  autoCapitalize="off"
                  autoComplete="current-password"
                  id="password"
                  name="password"
                  placeholder="password"
                  maxLength={20}
                  required
                  style={{
                    marginBottom: "10px",
                    borderTopLeftRadius: "0",
                    borderTopRightRadius: "0",
                  }}
                  onChange={e =>
                    setLoginDetails({ ...loginDetails, password: e.target.value })
                  }
                />
                {showPassword ? (
                  <IoEyeOutline className="eye-icon" onClick={toggleShowPassword} />
                ) : (
                  <IoEyeOffOutline className="eye-icon" onClick={toggleShowPassword} />
                )}
                <label className="floatingInput">Password</label>
              </section>

              <button
                type="submit"
                className={`w-100 mt-2 btn btn-lg btn-primary fw-medium fs-6 ${styles.trackingWide}`}
              >
                LOGIN
              </button>
            </form>
          </div>
        </div>
      </main>
    </div>
  );
}
