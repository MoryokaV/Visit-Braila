import { Navigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import Card from "../components/Card";
import { useEffect, useRef, useState } from "react";
import {
  IoCreateOutline,
  IoEyeOffOutline,
  IoEyeOutline,
  IoRemoveCircleOutline,
} from "react-icons/io5";
import { FieldValues, SubmitHandler, useForm } from "react-hook-form";
import TableCard from "../components/TableCard";
import { User } from "../models/UserModel";

export default function UsersPage() {
  const modalRef = useRef<HTMLDivElement>(null);
  const { user } = useAuth();
  const [users, setUsers] = useState<Array<User>>([]);

  if (!user || user.username !== "admin") {
    return <Navigate to="/login" />;
  }

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = () => {
    fetch("/api/fetchUsers")
      .then(response => response.json())
      .then(data => setUsers(data));
  };

  const deleteUser = async (id: string) => {
    if (confirm("Are you sure you want to delete the user")) {
      await fetch("/api/deleteUser/" + id, { method: "DELETE" });
      fetchUsers();
    }
  };

  const openEditModal = (id: string) => {
    modalRef.current!.dataset.user_id = id;
  };

  return (
    <div className="d-flex h-100">
      <div className="container-xl m-auto py-3">
        <div className="row justify-content-center gx-4 gy-3">
          <div className="col-sm-6 col-lg-5 col-xl-4">
            <Card title="Insert user">
              <InsertUserForm users={users} fetchUsers={fetchUsers} />
            </Card>
          </div>
          <div className="col-md-12 col-lg-7 col-xl-8">
            <TableCard title="Users" records={0}>
              <table>
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Full name</th>
                    <th>Username</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {users.map((user, index) => {
                    return (
                      <tr key={index}>
                        <td className="small-cell">{index + 1}</td>
                        <td>{user.fullname}</td>
                        <td>{user.username}</td>
                        <td className="small-cell text-center">
                          <button
                            className="btn-icon"
                            data-bs-toggle="modal"
                            data-bs-target="#modal"
                            onClick={() => openEditModal(user._id)}
                          >
                            <IoCreateOutline className="edit-icon" />
                          </button>
                          {user.username !== "admin" && (
                            <button
                              className="btn-icon"
                              onClick={() => deleteUser(user._id)}
                            >
                              <IoRemoveCircleOutline className="edit-icon" />
                            </button>
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </TableCard>
          </div>
        </div>
      </div>
      <EditPasswordModal modalRef={modalRef} />
    </div>
  );
}

interface InsertUserFormProps {
  users: User[];
  fetchUsers: () => void;
}

const InsertUserForm: React.FC<InsertUserFormProps> = ({ users, fetchUsers }) => {
  const [showPassword, setShowPassword] = useState(false);
  const toggleShowPassword = () => setShowPassword(!showPassword);

  const {
    register,
    formState: { isSubmitting },
    handleSubmit,
    reset,
  } = useForm();

  const onSubmit: SubmitHandler<FieldValues> = async data => {
    if (users.filter(stored_user => stored_user.username === data.username).length > 0) {
      alert("User already exists");
      return;
    }

    await fetch("/api/insertUser", {
      method: "POST",
      body: JSON.stringify(data),
      headers: { "Content-Type": "application/json; charset=UTF-8" },
    });

    fetchUsers();
    reset();
  };

  return (
    <form id="insert-user-form" className="row g-3" onSubmit={handleSubmit(onSubmit)}>
      <section className="col-12">
        <label htmlFor="fullname" className="form-label">
          Full name
        </label>
        <input
          type="text"
          id="fullname"
          className="form-control"
          spellCheck="false"
          autoCorrect="off"
          autoCapitalize="off"
          maxLength={22}
          {...register("fullname")}
          required
        />
      </section>
      <section className="col-12">
        <label htmlFor="username" className="form-label">
          Username
        </label>
        <input
          type="text"
          id="username"
          className="form-control"
          spellCheck="false"
          autoCorrect="off"
          autoCapitalize="off"
          {...register("username")}
          required
        />
      </section>
      <section className="col-12">
        <label htmlFor="password" className="form-label">
          Password
        </label>
        <div className="input-group">
          <input
            type={showPassword ? "text" : "password"}
            id="password"
            className="form-control rounded-end"
            spellCheck="false"
            autoCorrect="off"
            autoCapitalize="off"
            autoComplete="new-password"
            {...register("password")}
            maxLength={20}
            required
          />

          {showPassword ? (
            <IoEyeOutline className="eye-icon" onClick={toggleShowPassword} />
          ) : (
            <IoEyeOffOutline className="eye-icon" onClick={toggleShowPassword} />
          )}
        </div>
      </section>
      <section className="col-12">
        <button
          type="submit"
          className={`btn btn-primary ${isSubmitting && "loading-btn"}`}
        >
          <span>Insert</span>
        </button>
      </section>
    </form>
  );
};

interface EditPasswordModalProps {
  modalRef: React.RefObject<HTMLDivElement>;
}

const EditPasswordModal: React.FC<EditPasswordModalProps> = ({ modalRef }) => {
  const [newPassword, setNewPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const toggleShowPassword = () => setShowPassword(!showPassword);

  const closeModal = () => {
    window.bootstrap.Modal.getInstance(modalRef.current!)?.hide();
    setNewPassword("");
  };

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    await fetch("/api/editUserPassword/" + modalRef.current!.dataset.user_id, {
      method: "PUT",
      body: JSON.stringify({ new_password: newPassword }),
      headers: {
        "Content-Type": "application/json",
      },
    });

    closeModal();
  };

  return (
    <div
      ref={modalRef}
      className="modal fade"
      id="modal"
      tabIndex={-1}
      aria-hidden="true"
    >
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">Edit user account</h5>
            <button
              type="button"
              className="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div className="modal-body">
            <form id="edit-user-form" className="row g-3" onSubmit={onSubmit}>
              <section className="col-12">
                <label htmlFor="new-password" className="form-label">
                  New password
                </label>
                <div className="input-group">
                  <input
                    type={showPassword ? "text" : "password"}
                    id="new-password"
                    className="form-control rounded-end"
                    spellCheck="false"
                    autoCorrect="off"
                    autoCapitalize="off"
                    autoComplete="new-password"
                    name="new-password"
                    maxLength={20}
                    onChange={e => setNewPassword(e.currentTarget.value)}
                    required
                  />

                  {showPassword ? (
                    <IoEyeOutline className="eye-icon" onClick={toggleShowPassword} />
                  ) : (
                    <IoEyeOffOutline className="eye-icon" onClick={toggleShowPassword} />
                  )}
                </div>
              </section>
              <section className="col-12">
                <button type="submit" className="btn btn-primary">
                  <span>Update</span>
                </button>
              </section>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};
