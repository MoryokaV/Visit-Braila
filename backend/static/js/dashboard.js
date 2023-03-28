import { openEditEventModal, openEditHotelModal, openEditRestaurantModal, openEditSightModal, openEditTourModal } from './modal.js';

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
          <td><a href=${sight.external_link} target="_blank">${sight.external_link}</a></td>
          <td id=${sight._id}>
            <div class="group">
              <button class="btn-icon action-edit-sight" data-bs-toggle="modal" data-bs-target="#sight-modal"><ion-icon class="edit-icon" name="create-outline"></ion-icon></button>
              <button class="btn-icon action-delete-sight"><ion-icon class="edit-icon" name="remove-circle-outline"></ion-icon></button>
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
          <td><a href=${tour.external_link} target="_blank">${tour.external_link}</a></td>
          <td id=${tour._id}>
            <div class="group">
              <button class="btn-icon action-edit-tour" data-bs-toggle="modal" data-bs-target="#tour-modal"><ion-icon class="edit-icon" name="create-outline"></ion-icon></button>
              <button class="btn-icon action-delete-tour"><ion-icon class="edit-icon" name="remove-circle-outline"></ion-icon></button>
            </div>
          </td>
        </tr>`
    );
  });
}

export const fetchRestaurants = async () => {
  const data = await $.getJSON("/api/fetchRestaurants");

  $("#restaurants-records").text(getRecords(data));
  $("#restaurants-table tbody").empty();

  data.map((restaurant) => {
    restaurant.tags = restaurant.tags.join(", ");

    $("#restaurants-table").append(
      `<tr>
          <td>${restaurant._id}</td>
          <td>${restaurant.name}</td>
          <td>${restaurant.tags}</td>
          <td><a href=${restaurant.external_link} target="_blank">${restaurant.external_link}</a></td>
          <td id=${restaurant._id}>
            <div class="group">
              <button class="btn-icon action-edit-restaurant" data-bs-toggle="modal" data-bs-target="#restaurant-modal"><ion-icon class="edit-icon" name="create-outline"></ion-icon></button>
              <button class="btn-icon action-delete-restaurant"><ion-icon class="edit-icon" name="remove-circle-outline"></ion-icon></button>
            </div>
          </td>
        </tr>`
    );
  });
};

export const fetchHotels = async () => {
  const data = await $.getJSON("/api/fetchHotels");

  $("#hotels-records").text(getRecords(data));
  $("#hotels-table tbody").empty();

  data.map((hotel) => {
    hotel.tags = hotel.tags.join(", ");

    $("#hotels-table").append(
      `<tr>
        <td>${hotel._id}</td>
        <td>${hotel.name}</td>
        <td class="stars">${"★".repeat(hotel.stars)}</td>
        <td>${hotel.tags}</td>
        <td><a href=${hotel.external_link} target="_blank">${hotel.external_link}</a></td>
        <td id=${hotel._id}>
          <div class="group">
            <button class="btn-icon action-edit-hotel" data-bs-toggle="modal" data-bs-target="#hotel-modal"><ion-icon class="edit-icon" name="create-outline"></ion-icon></button>
            <button class="btn-icon action-delete-hotel"><ion-icon class="edit-icon" name="remove-circle-outline"></ion-icon></button>
          </div>
        </td>
      </tr>`
    )
  });
}

const convert2LocalDate = (iso_date) => {
  const date = new Date(iso_date);
  const localDate = new Date(date.getTime() - date.getTimezoneOffset() * 1000 * 60);

  return localDate;
}

export const fetchEvents = async () => {
  const data = await $.getJSON("/api/fetchEvents");

  $("#events-records").text(getRecords(data));
  $("#events-table tbody").empty();

  data.map((event) => {
    const date_time = new Intl.DateTimeFormat('ro-RO', { dateStyle: "short", timeStyle: 'short', }).format(convert2LocalDate(event.date_time));
    let end_date_time = undefined;
    if (event.end_date_time !== null) {
      end_date_time = new Intl.DateTimeFormat('ro-RO', { dateStyle: "short", timeStyle: 'short', }).format(convert2LocalDate(event.end_date_time));
    }

    $("#events-table").append(
      `<tr>
          <td>${event._id}</td>
          <td>${event.name}</td>
          <td>${end_date_time === undefined ? date_time : date_time + " &rarr; " + end_date_time}</td >
          <td id=${event._id}>
            <div class="group">
              <button class="btn-icon action-edit-event" data-bs-toggle="modal" data-bs-target="#event-modal"><ion-icon class="edit-icon" name="create-outline"></ion-icon></button>
              <button class="btn-icon action-delete-event"><ion-icon class="edit-icon" name="remove-circle-outline"></ion-icon></button>
            </div>
          </td>
      </tr> `
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
  });

  await fetchRestaurants();

  $("#restaurants-table").on('click', ".action-delete-restaurant", async function() {
    if (confirm("Are you sure you want to delete the entry?")) {
      await $.ajax({
        url: "/api/deleteRestaurant/" + $(this).parent().parent().attr("id"),
        type: "DELETE",
      });

      fetchRestaurants();
    }
  });

  $("#restaurants-table").on('click', ".action-edit-restaurant", async function() {
    await openEditRestaurantModal($(this).parent().parent().attr("id"));
  });

  await fetchHotels();

  $("#hotels-table").on('click', ".action-delete-hotel", async function() {
    if (confirm("Are you sure you want to delete the entry?")) {
      await $.ajax({
        url: "/api/deleteHotel/" + $(this).parent().parent().attr("id"),
        type: "DELETE",
      });

      fetchHotels();
    }
  });

  $("#hotels-table").on('click', ".action-edit-hotel", async function() {
    await openEditHotelModal($(this).parent().parent().attr("id"));
  });

  await fetchEvents();

  $("#events-table").on('click', ".action-delete-event", async function() {
    if (confirm("Are you sure you want to delete the entry?")) {
      await $.ajax({
        url: "/api/deleteEvent/" + $(this).parent().parent().attr("id"),
        type: "DELETE",
      });

      fetchEvents();
    }
  });

  $("#events-table").on('click', ".action-edit-event", async function() {
    await openEditEventModal($(this).parent().parent().attr("id"));
  });
});
