import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { Outlet, useNavigate } from "react-router-dom";

type UserType = {
  fullname: string;
  username: string;
} | null;

type AuthContextType = {
  user: UserType;
  login: (user: UserType, url: string) => void;
  logout: () => void;
};

const AuthContext = createContext<AuthContextType>(null!);

export const AuthProvider = () => {
  const [user, setUser] = useState<UserType>(null);
  const [loading, setLoading] = useState(true);

  const navigate = useNavigate();

  useEffect(() => {
    getSessionData().then(data => {
      setUser(data);
      setLoading(false);
    });
  }, []);

  const login = (user: UserType, url: string) => {
    setUser(user);

    navigate(url);
  };

  const logout = () => {
    setUser(null);

    navigate("/login");
  };

  const value = useMemo(
    () => ({
      user,
      login,
      logout,
    }),
    [user],
  );

  if (loading) {
    return <></>;
  }

  return (
    <AuthContext.Provider value={value}>
      <Outlet />
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  return useContext(AuthContext);
};

const getSessionData = async () => {
  const response = await fetch("/api/user");
  const user = await response.json();

  if (Object.keys(user).length === 0) {
    return null;
  }

  return user;
};
