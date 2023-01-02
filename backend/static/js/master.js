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
        <td>${user.username}</td>
        <td class="small-cell text-center" id=${user._id}>
          <button class="btn-icon action-delete-user"><ion-icon class="edit-icon" name="remove-circle-outline"></ion-icon></button>
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

  $("#insert-user-form").submit(async function(e) {
    e.preventDefault();

    const user = {
      "username": $("#username").val(),
      "password": $("#password").val(),
    };

    if (users.filter((stored_user) => stored_user.username === user.username).length > 0) {
      alert("User already exists");
      return;
    }

    startLoadingAnimation($(this));

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
