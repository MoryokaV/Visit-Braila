import { openEditSightModal } from './modal.js';

const getRecords = (data) => {
  if (data.length === 0) return "No records";
  else if (data.length === 1) return "1 record";
  else return `${data.length} records`;
};

export const tags = ["Relax", "History", "Food", "Shopping", "Religion"]

export const fetchSights = async () => {
  const data = await $.getJSON(window.origin + "/api/fetchSights");

  $("#sights-records").text(getRecords(data));
  $("#sights-table tbody").empty();

  data.map((sight) => {
    $("#sights-table").append(
        `<tr id=${sight._id}>
          <td>${sight._id}</td>
          <td>${sight.name}</td>
          <td>${sight.tags}</td>
          <td>${sight.position}</td>
          <td id=${sight._id} class="group">
            <button class="btn action-edit-sight"><ion-icon class="icon" name="create-outline"></ion-icon></button>
            <button class="btn action-delete-sight"><ion-icon class="icon" name="trash-outline"></ion-icon></button>
          </td>
        </tr>`
      );
  });
}; 

const deleteSight = async (_id) => {
  $.ajax({
    url: window.origin + "/api/deleteSight/" + _id,
    type: "DELETE",
  });
  await fetchSights();
};

$(document).ready(async function () {
  await fetchSights();

  $("#sights-table").on('click', ".action-delete-sight", function () {
    deleteSight($(this).parent().attr("id"));
  });

  $("#sights-table").on('click', ".action-edit-sight", async function () {
    await openEditSightModal($(this).parent().attr("id"));
    $(".modal").addClass("show");
  });
});
