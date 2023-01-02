import { fetchEvents, fetchSights, fetchTours } from './dashboard.js';
import {
  startLoadingAnimation,
  endLoadingAnimation,
  nameRegExp,
  nameRegExpTitle,
  addressRegExp,
  addressRegExpTitle,
  idRegExp,
  idRegExpTitle,
  latitudeRegExp,
  latitudeRegExpTitle,
  longitudeRegExp,
  longitudeRegExpTitle,
  addImages,
  appendImageElement,
  removeImage
} from './utils.js';

let sight = {};
let tour = {};
let event = {};
let current_images = [];
let formData = undefined;
let images_to_delete = [];
let quill = undefined;

const appendActiveTags = () => {
  $("#sight-modal #active-tags").empty()
  sight.tags.map((tag) => $("#sight-modal #active-tags").append(`<span class="badge bg-primary">${tag}</span>`));
}

const linkInputElement = link => `<input value="${link}" type="text" size="10" class="stage-link form-control text-primary" placeholder="Sight id" pattern="${idRegExp}" title="${idRegExpTitle}" required />`;

const appendStages = () => {
  $("#tour-modal #stages").empty();

  tour.stages.map((stage, index) => {
    $("#stages").append(
      `<div class="stage">
        <input type="text" size="${stage.text.length}" class="form-control" maxlength="55" required /> 
        <ion-icon name="link-outline" class="stage-input-icon ${stage.sight_link !== "" ? "active" : ""}"></ion-icon>
      </div>
      ${stage.sight_link !== "" ? linkInputElement(stage.sight_link) : ``}
      ${index === tour.stages.length - 1 ?
        `<button type="button" class="btn btn-icon text-primary" id="add-stage"> 
          <ion-icon name="add-outline"></ion-icon> 
        </button>`
        :
        `-`
      }`
    );

    $("#stages > div").eq(index).find(" > input").val(stage.text);
  });

  $("#tour-modal #stages .stage input").attr("pattern", addressRegExp).attr("title", addressRegExpTitle);
}

const getOffsettedDate = (timestamp) => {
  const date = new Date(timestamp);
  const localDate = new Date(date.getTime() - date.getTimezoneOffset() * 1000 * 60);

  return localDate.toISOString().slice(0, -8);
}

const convert2LocalDate = (iso_date) => {
  const date = new Date(iso_date);
  const localDate = new Date(date.getTime() - 2 * (date.getTimezoneOffset() * 1000 * 60));

  return localDate.toISOString().slice(0, -8);
}

const getMinEndDate = () => {
  const start_date = new Date($("#event-datetime").val());
  const day = 1 * 1000 * 60 * 60 * 24;
  const convertedDate = new Date(start_date.getTime() + day);
  convertedDate.setHours(0, 0, 0, 0);

  return getOffsettedDate(convertedDate);
}

export const openEditSightModal = async (id) => {
  sight = await $.getJSON("/api/findSight/" + id);
  current_images = [...sight.images];
  formData = new FormData();
  images_to_delete = [];

  // NAME
  $("#sight-name").val(sight.name);

  // TAGS
  appendActiveTags();

  $('#sight-modal #tags option:gt(0)').remove()
  const tags = await $.getJSON("/api/fetchTags");
  tags.map((tag) => $("#sight-modal #tags").append(`<option value="${tag.name}">${tag.name}</option>`));

  // DESCRIPTION
  quill = new Quill("#sight-description", {
    theme: "snow",
  });
  $("#sight-description .ql-editor").html(sight.description)

  // IMAGES
  sight.images.map((image) => appendImageElement(image, true));

  $("#sight-primary-image").attr("max", sight.images.length);
  $("#sight-primary-image").val(sight.primary_image);

  // COORDINATES
  $("#sight-modal #sight-latitude").val(sight.latitude);
  $("#sight-modal #sight-longitude").val(sight.longitude);

  // EXTERNAL LINK
  $("#sight-external-link").val(sight.external_link)
}

export const openEditTourModal = async (id) => {
  tour = await $.getJSON("/api/findTour/" + id);
  current_images = [...tour.images];
  formData = new FormData();
  images_to_delete = [];

  // NAME
  $("#tour-name").val(tour.name);

  // STAGES
  appendStages();

  // DESCRIPTION
  quill = new Quill("#tour-description", {
    theme: "snow",
  });
  $("#tour-description .ql-editor").html(tour.description);

  // IMAGES
  tour.images.map((image) => appendImageElement(image, true));

  $("#tour-primary-image").attr("max", tour.images.length);
  $("#tour-primary-image").val(tour.primary_image);

  // LENGTH
  $("#tour-modal #tour-length").val(tour.length);

  // EXTERNAL LINK 
  $("#tour-external-link").val(tour.external_link);
}

export const openEditEventModal = async (id) => {
  event = await $.getJSON("/api/findEvent/" + id);
  current_images = [...event.images];
  formData = new FormData();
  images_to_delete = [];

  // NAME
  $("#event-name").val(event.name);

  // DATE & TIME
  $("#event-datetime").focus(function() {
    $("#event-datetime").attr("min", getOffsettedDate(Date.now()));
  });

  $("#event-datetime").val(convert2LocalDate(event.date_time));

  if (event.end_date_time !== null) {
    $("#multiple-days").prop("checked", true);

    $("#end-event-datetime").parent().remove()
    $("#multiple-days").parent().parent().after(`
      <section class="col-12">
        <label for="end-datetime" class="form-label">End date & time</label>
        <input id="end-event-datetime" class="form-control" type="datetime-local" name="end-datetime" required></input>
      </section>
    `);

    $("#end-event-datetime").val(convert2LocalDate(event.end_date_time));
  }

  // DESCRIPTION
  quill = new Quill("#event-description", {
    theme: "snow",
  });
  $("#event-description .ql-editor").html(event.description);

  // IMAGES
  event.images.map((image) => appendImageElement(image, true));

  $("#event-primary-image").attr("max", event.images.length);
  $("#event-primary-image").val(event.primary_image);
}

$(document).ready(async function() {
  $("#sight-modal").on("hidden.bs.modal", function() {
    $(".ql-toolbar").remove();
    $(".img-container").empty();
  })

  // SIGHT NAME
  $("#sight-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);

  // SIGHT TAGS
  $("#sight-modal #tags").change(function() {
    if (!sight.tags.includes($(this).val())) {
      $("#sight-modal #tag-btn")
        .removeClass("text-danger")
        .text("Add")
        .off("click")
        .click(function() {
          if (sight.tags.length === 3) {
            alert("You cannot use more than 3 tags!");
            return;
          }

          sight.tags.push($("#sight-modal #tags").val());

          appendActiveTags();

          $(this).off("click");
          $("#sight-modal #tags").val("-");
        });
    } else {
      $("#sight-modal #tag-btn")
        .addClass("text-danger")
        .text("Remove")
        .off("click")
        .click(function() {
          const index = sight.tags.indexOf($("#sight-modal #tags").val());
          sight.tags.splice(index, 1);

          appendActiveTags();

          $(this).removeClass("text-danger").text("Add").off("click");
          $("#sight-modal #tags").val("-");
        });
    }
  });

  // SIGHT IMAGES 
  $('#sight-images').change(function() {
    $(this).prop("required", false);

    addImages($(this).prop('files'), "/static/media/sights/", false, current_images, formData, $("#sight-primary-image"));

    $(this).val(null);
  });

  $("#sight-modal .img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), false, current_images, formData, $("#sight-primary-image"), $("#sight-images"));

    //mark for deletion
    if (sight.images.includes(current_images[$(this).parent().index()])) {
      images_to_delete.push(current_images[$(this).parent().index()]);
    }
  });

  // SIGHT COORDINATES
  $("#sight-latitude").attr("pattern", latitudeRegExp).attr("title", latitudeRegExpTitle);
  $("#sight-longitude").attr("pattern", longitudeRegExp).attr("title", longitudeRegExpTitle);

  // SIGHT SUBMIT
  $("#sight-modal form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    sight.name = $("#sight-name").val();
    sight.description = quill.root.innerHTML;
    sight.primary_image = parseInt($("#sight-primary-image").val());
    sight.latitude = parseFloat($("#sight-latitude").val());
    sight.longitude = parseFloat($("#sight-longitude").val());
    sight.external_link = $("#sight-external-link").val();

    try {
      if (formData.getAll("files[]").length > 0)
        await $.ajax({
          type: "POST",
          url: "/api/uploadImages/sights",
          contentType: false,
          data: formData,
          cache: false,
          processData: false,
          statusCode: {
            413: function() {
              alert("Files size should be less than 15MB")
            }
          },
        });

      sight.images = [...current_images];

      await $.ajax({
        url: "/api/editSight",
        type: "PUT",
        data: JSON.stringify({ "images_to_delete": images_to_delete, "sight": sight }),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });

      await fetchSights();
      endLoadingAnimation($(this));
      $("#sight-modal").modal('hide');
    } catch {
      endLoadingAnimation($(this));
    }
  });

  $("#tour-modal").on("hidden.bs.modal", function() {
    $(".ql-toolbar").remove();
    $(".img-container").empty();
  })

  // TOUR NAME
  $("#tour-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);

  // TOUR STAGES
  $("#stages").on('click', ".stage-input-icon", function() {
    if ($(this).hasClass("active")) {
      $(this).removeClass("active");

      //remove sight link
      $(this).parent().next("input").remove();
      tour.stages[$("#stages > div").index($(this).parent())].sight_link = "";
    } else {
      $(this).addClass("active");

      //add sight link
      $(this).parent().after(linkInputElement(""));
    }
  });

  $("#tour-modal #stages").on('click', "#add-stage", function() {
    tour.stages.push({ text: "", sight_link: "" });
    appendStages();
  });

  $("#tour-modal #stages").on('input', ".stage input", function() {
    const index = $("#stages > div").index($(this).parent());
    const stage = $(this).val();

    $(this).attr("size", stage.length);

    tour.stages[index].text = stage;
  });

  $("#tour-modal #stages").on('keydown', ".stage input", function(e) {
    const index = $("#stages > div").index($(this).parent());

    if ($(this).val() === "" && index !== 0 && index !== 1 && e.keyCode === 8) {
      tour.stages.splice(index, 1);
      appendStages();

      return;
    }
  });

  $("#stages").on('input', ".stage-link", function() {
    const index = $("#stages > div").index($(this).prev("div"));
    const link = $(this).val();

    tour.stages[index].sight_link = link;
  });

  // TOUR IMAGES 
  $('#tour-images').change(function() {
    $(this).prop("required", false);

    addImages($(this).prop('files'), "/static/media/tours/", false, tour.images, formData, $("#tour-primary-image"));

    $(this).val(null);
  });

  $("#tour-modal .img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), false, current_images, formData, $("#tour-primary-image"), $("#tour-images"));

    //mark for deletion
    if (tour.images.includes(current_images[$(this).parent().index()])) {
      images_to_delete.push(current_images[$(this).parent().index()]);
    }
  });

  // TOUR SUBMIT 
  $("#tour-modal form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    tour.name = $("#tour-name").val();
    tour.description = quill.root.innerHTML;
    tour.primary_image = parseInt($("#tour-primary-image").val());
    tour.length = parseFloat($("#tour-length").val());
    tour.external_link = $("#tour-external-link").val();

    try {
      if (formData.getAll("files[]").length > 0)
        await $.ajax({
          type: "POST",
          url: "/api/uploadImages/tours",
          contentType: false,
          data: formData,
          cache: false,
          processData: false,
          statusCode: {
            413: function() {
              alert("Files size should be less than 15MB")
            }
          },
        });

      tour.images = [...current_images];

      await $.ajax({
        url: "/api/editTour",
        type: "PUT",
        data: JSON.stringify({ "images_to_delete": images_to_delete, "tour": tour }),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });

      await fetchTours();
      endLoadingAnimation($(this));
      $("#tour-modal").modal('hide');
    } catch {
      endLoadingAnimation($(this));
    }
  });

  $("#event-modal").on("hidden.bs.modal", function() {
    $(".ql-toolbar").remove();
    $(".img-container").empty();
  })

  // EVENT NAME
  $("#event-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);

  // EVENT DATE
  $("#multiple-days").on('change', function() {
    if ($(this).prop('checked') === true) {
      $(this).parent().parent().after(`
        <div class="col-12">
          <label for="end-datetime" class="form-label">End date & time</label>
          <input id="end-event-datetime" class="form-control" type="datetime-local" name="end-datetime" required></input>
        </div>
      `);
    } else {
      $(this).parent().parent().next().remove();
    }
  });

  $("#event-modal").on('focus', '#end-event-datetime', function() {
    $("#end-event-datetime").attr("min", getMinEndDate());
  });

  // EVENT IMAGES 
  $('#event-images').change(function() {
    $(this).prop("required", false);

    addImages($(this).prop('files'), "/static/media/events/", false, event.images, formData, $("#event-primary-image"));

    $(this).val(null);
  });

  $("#event-modal .img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), false, event.images, formData, $("#event-primary-image"), $("#event-images"));
  });

  //EVENT SUBMIT
  $("#event-modal form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    event.name = $("#event-name").val();
    event.date_time = new Date($("#event-datetime").val());
    if ($("#multiple-days").prop('checked')) {
      event.end_date_time = new Date($("#end-event-datetime").val());
    } else {
      event.end_date_time = undefined;
    }
    event.description = quill.root.innerHTML;
    event.primary_image = parseInt($("#event-primary-image").val());

    if (event.date_time < Date.now()) {
      $("#event-datetime").focus();

      endLoadingAnimation($(this));
      return false;
    }

    if (event.end_date_time < event.date_time) {
      $("#end-event-datetime").focus();

      endLoadingAnimation($(this));
      return false;
    }

    try {
      await $.ajax({
        type: "POST",
        url: "/api/uploadImages/events",
        contentType: false,
        data: formData,
        cache: false,
        processData: false,
        statusCode: {
          413: function() {
            alert("Files size should be less than 15MB")
          }
        },
      });

      event.images = [...current_images];

      await $.ajax({
        url: "/api/editEvent",
        type: "PUT",
        data: JSON.stringify({ "images_to_delete": images_to_delete, "event": event }),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });

      await fetchEvents();
      endLoadingAnimation($(this));
      $("#event-modal").modal('hide');
    } catch {
      endLoadingAnimation($(this));
    }
  });
});
