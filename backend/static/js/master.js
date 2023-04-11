import { endLoadingAnimation, startLoadingAnimation } from "./utils.js";

let users = [];

const getRecords = (data) => {
  if (data.length === 0) return "No records";
  else if (data.length === 1) return "1 record";
  else return `${data.length} records`;
};

const fetchUsers = async () => {
  users = await $.getJSON("/api/fetchUsers");

  $("#users-records").text(getRecords(users));
  $("#users-table tbody").empty();

  users.map((user, index) => {
    $("#users-table").append(
      `<tr>
        <td class="small-cell">${index + 1}</td>
        <td>${user.fullname}</td>
        <td>${user.username}</td>
        <td class="small-cell text-center" id=${user._id}>
          ${user.username === "admin" ? `` : `<button class="btn-icon action-delete-user"><ion-icon class="edit-icon" name="remove-circle-outline"></ion-icon></button>`}
          <button class="btn-icon action-edit-user" data-bs-toggle="modal" data-bs-target="#edit-user-modal"><ion-icon class="edit-icon" name="create-outline"></ion-icon></button>
        </td>
      </tr>`
    );
  });
};

$(document).ready(async function() {
  await fetchUsers();

  $("#users-table").on('click', ".action-delete-user", async function() {
    if (confirm("Are you sure you want to delete the entry?")) {
      await $.ajax({
        type: "DELETE",
        url: "/api/deleteUser/" + $(this).parent().attr("id"),
      });

      await fetchUsers();
    }
  });

  $("#users-table").on('click', ".action-edit-user", async function() {
    $("#edit-user-modal").attr("data-id", $(this).parent().attr("id"));
  });

  $(".eye-icon").on("click", function() {
    const passwordField = $(this).siblings();

    if (passwordField.attr("type") === "password") {
      $(this).attr("name", "eye-outline");
      passwordField.attr("type", "text");
    } else {
      $(this).attr("name", "eye-off-outline");
      passwordField.attr("type", "password");
    }
  });

  $("#edit-user-modal").on("hidden.bs.modal", function() {
    $("#edit-user-form")[0].reset();
  });

  $("#edit-user-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));
    await new Promise((resolve) => setTimeout(resolve, 300));

    await $.ajax({
      type: "PUT",
      url: "/api/editUserPassword/" + $("#edit-user-modal").attr("data-id"),
      contentType: "application/json; charset=UTF-8",
      processData: false,
      data: JSON.stringify({ "new_password": $("#new-password").val() }),
    });

    endLoadingAnimation($(this));
    $(this)[0].reset();
    $("#edit-user-modal").modal("hide");
  });

  $("#insert-user-form").submit(async function(e) {
    e.preventDefault();

    const user = {
      "fullname": $("#fullname").val(),
      "username": $("#username").val(),
      "password": $("#password").val(),
    };

    if (users.filter((stored_user) => stored_user.username === user.username).length > 0) {
      alert("User already exists");
      return;
    }

    startLoadingAnimation($(this));
    await new Promise((resolve) => setTimeout(resolve, 300));

    await $.ajax({
      type: "POST",
      url: "/api/insertUser",
      contentType: "application/json; charset=UTF-8",
      processData: false,
      data: JSON.stringify(user),
    });

    await fetchUsers();

    endLoadingAnimation($(this));

    $(this)[0].reset();
  });
});
