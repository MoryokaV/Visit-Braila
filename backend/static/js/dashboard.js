import { openEditSightModal, openEditTourModal } from './modal.js';

const getRecords = (data) => {
  if (data.length === 0) return "No records";
  else if (data.length === 1) return "1 record";
  else return `${data.length} records`;
};

export const fetchSights = async () => {
  const data = await $.getJSON("/api/fetchSights");

  $("#sights-records").text(getRecords(data));
  $("#sights-table tbody").empty();

  data.map((sight) => {
    sight.tags = sight.tags.join(", ");

    $("#sights-table").append(
      `<tr>
          <td>${sight._id}</td>
          <td>${sight.name}</td>
          <td>${sight.tags}</td>
          <td><a href=${sight.position} target="_blank" class="link">${sight.position}</a></td>
          <td id=${sight._id}>
            <div class="group">
              <button class="btn action-edit-sight"><ion-icon class="small-icon" name="create-outline"></ion-icon></button>
              <button class="btn action-delete-sight"><ion-icon class="small-icon" name="remove-circle-outline"></ion-icon></button>
            </div>
          </td>
        </tr>`
    );
  });
};

export const fetchTours = async () => {
  const data = await $.getJSON("/api/fetchTours");

  $("#tours-records").text(getRecords(data));
  $("#tours-table tbody").empty();

  data.map((tour) => {
    tour.stages = tour.stages.map((stage) => stage.text).join(" - ");

    $("#tours-table").append(
      `<tr>
          <td>${tour._id}</td>
          <td>${tour.name}</td>
          <td>${tour.stages}</td>
          <td><a href=${tour.route} target="_blank" class="link">${tour.route}</a></td>
          <td id=${tour._id}>
            <div class="group">
              <button class="btn action-edit-tour"><ion-icon class="small-icon" name="create-outline"></ion-icon></button>
              <button class="btn action-delete-tour"><ion-icon class="small-icon" name="remove-circle-outline"></ion-icon></button>
            </div>
          </td>
        </tr>`
    );
  });
}

$(document).ready(async function() {
  await fetchSights();

  $("#sights-table").on('click', ".action-delete-sight", async function() {
    if (confirm("Are you sure you want to delete the entry?")) {
      await $.ajax({
        url: "/api/deleteSight/" + $(this).parent().parent().attr("id"),
        type: "DELETE",
      });

      fetchSights();
    }
  });

  $("#sights-table").on('click', ".action-edit-sight", async function() {
    await openEditSightModal($(this).parent().parent().attr("id"));
    $("#sight-modal").addClass("show");
  });

  await fetchTours();

  $("#tours-table").on('click', ".action-delete-tour", async function() {
    if (confirm("Are you sure you want to delete the entry?")) {
      await $.ajax({
        url: "/api/deleteTour/" + $(this).parent().parent().attr("id"),
        type: "DELETE",
      });

      fetchTours();
    }
  });

  $("#tours-table").on('click', ".action-edit-tour", async function() {
    await openEditTourModal($(this).parent().parent().attr("id"));
    $("#tour-modal").addClass("show");
  });
});
