import {
  startLoadingAnimation,
  nameRegExp,
  nameRegExpTitle,
  endLoadingAnimation,
  addImages,
  removeImage
} from './utils.js';

let quill = undefined;
let formData = new FormData();
let event = {
  name: "",
  date_time: new Date(),
  end_date_time: undefined,
  images: [],
  primary_image: 1,
  description: ``,
};

const convert2LocalDate = (timestamp) => {
  const date = new Date(timestamp);
  const localDate = new Date(date.getTime() - date.getTimezoneOffset() * 1000 * 60);

  return localDate.toISOString().slice(0, -8);
}

const getMinEndDate = () => {
  const start_date = new Date($("#event-datetime").val());
  const day = 1 * 1000 * 60 * 60 * 24;
  const convertedDate = new Date(start_date.getTime() + day);
  convertedDate.setHours(0, 0, 0, 0);

  return convert2LocalDate(convertedDate);
}

$(document).ready(async function() {
  // NAME
  $("#event-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);
  $("#event-name").on('input', function() {
    $("#preview-name").text($(this).val());
  });

  // DESCRIPTION
  quill = new Quill("#event-description", {
    theme: "snow",
  });

  quill.on('text-change', function() {
    $("#preview-description").html(quill.root.innerHTML);
  });

  // IMAGES 
  $("#event-images").change(function() {
    $(this).prop("required", false);

    addImages($(this).prop('files'), "/static/media/events/", true, event.images, formData, $("#event-primary-image"));

    $(this).val(null);
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), true, event.images, formData, $("#event-primary-image"), $("#event-images"));
  });

  $("#event-primary-image").on('change', function() {
    $("#preview-primary-image").prop("src", $("#preview-images img").eq($(this).val() - 1).prop("src"));
  });

  // DATE & TIME
  $("#event-datetime").focus(function() {
    $("#event-datetime").attr("min", convert2LocalDate(Date.now()));
  });
  $("#event-datetime").on('change', function() {
    const date = new Date($(this).val());
    const formatedDate = new Intl.DateTimeFormat('ro-RO', { dateStyle: "long", timeStyle: 'short', }).format(date);

    $("#start-date").text(formatedDate);
  });

  $("#multiple-days").on('change', function() {
    if ($(this).prop('checked') === true) {
      $(this).parent().parent().after(`
        <section class="col-12">
          <label for="end-event-datetime" class="form-label">End date & time</label>
          <input id="end-event-datetime" type="datetime-local" class="form-control" name="end-datetime" required></input>
        </section>
      `);
    } else {
      $(this).parent().parent().next().remove();
      $("#end-date").html(``);
    }
  });

  $("#insert-event-form").on('focus', '#end-event-datetime', function() {
    $("#end-event-datetime").attr("min", getMinEndDate());
  });
  $("#insert-event-form").on('change', '#end-event-datetime', function() {
    const date = new Date($(this).val());
    const formatedDate = new Intl.DateTimeFormat('ro-RO', { dateStyle: "long", timeStyle: 'short', }).format(date);

    $("#end-date").html(`&rarr; ${formatedDate}`);
  });

  // SUBMIT
  $("#insert-event-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    event.name = $("#event-name").val();
    event.date_time = new Date($("#event-datetime").val());
    if ($("#multiple-days").prop('checked')) {
      event.end_date_time = new Date($("#end-event-datetime").val());
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

      await $.ajax({
        url: "/api/insertEvent",
        type: "POST",
        data: JSON.stringify({ "notify": $("#send-notif").prop("checked"), "event": event }),
        processData: false,
        contentType: "application/json; charse=UTF-8",
      });

      location.reload();
    } catch {
      endLoadingAnimation($(this));
    }
  });
});
