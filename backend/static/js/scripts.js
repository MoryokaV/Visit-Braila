import { openUpdateModal } from './modal.js';

const getRecords = (data) => {
  if (data.length === 0) return "No records";
  else if (data.length === 1) return "1 record";
  else return `${data.length} records`;
};


const fetchSights = async () => {
  const data = await $.getJSON(window.origin + "/api/fetchSights");

  $(".card-header p").text(getRecords(data));
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

  $(".action-delete-sight").click(function () {
    deleteSight($(this).parent().attr("id"));
  });

  $(".action-edit-sight").click(async function () {
    await openUpdateModal($(this).parent().attr("id"));

    $(".modal").addClass("show");
  });

  $(".close-btn").click(function () {
    $(".modal").removeClass("show");
  });
}; 

const deleteSight = async (_id) => {
  $.ajax({
    url: window.origin + "/api/deleteSight/" + _id,
    type: "DELETE",
  });
  await fetchSights();
};

$(document).ready(function () {
  fetchSights();
});
