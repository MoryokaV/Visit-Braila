import {
  getFilename,
  startLoadingAnimation,
  nameRegExp,
  nameRegExpTitle,
  endLoadingAnimation
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

const appendImageElement = (image) => {
  $(".img-container").append(
    `<li class="highlight-onhover">
        <a class="group">
          <ion-icon name="cloud-upload-outline"></ion-icon>
          ${image}
        </a>
        <button type="button" class="btn icon-btn remove-img-btn">
          <ion-icon name="close-outline"></ion-icon>
        </button>
      </li>`
  );

  $("#event-primary-image").attr("max", event.images.length);
}

const addPreviewImages = async (images) => {
  function getBase64(image) {
    const reader = new FileReader();

    return new Promise(resolve => {
      reader.onload = e => {
        resolve(e.target.result)
      };

      reader.readAsDataURL(image);
    });
  }

  const blobs = await Promise.all(images.map(image => getBase64(image)));

  blobs.map((blob) => $("#preview-images").append(`<img src="${blob}" class="img-sm">`));

  if ($("#preview-primary-image").attr("src") === undefined) {
    $("#preview-primary-image").prop("src", $("#preview-images img").eq(0).prop("src"));
  }
}

const addImages = (elem) => {
  const images = Array.from(elem.prop('files')).filter((image) => {
    if (event.images.includes("/static/media/events/" + image.name)) {
      alert(`'${image.name}' is already present in list!`);
      return false;
    }

    return true;
  });

  addPreviewImages(images);

  images.map((image) => {
    formData.append("files[]", image);
    event.images.push("/static/media/events/" + image.name);

    appendImageElement(image.name);
  });

  elem.val(null);
}

const removePreviewImage = (elem) => {
  if (event.images.length === 1) {
    $("#preview-primary-image").removeAttr("src");
  }

  $("#preview-images img").eq(elem.parent().index()).remove();

  $("#event-primary-image").change();
}

const removeImage = (elem) => {
  if (parseInt($("#event-primary-image").val()) === event.images.length) {
    $("#event-primary-image").val(event.images.length - 1);
  }

  if (event.images.length === 1) {
    $("#event-images").prop("required", true);
    $("#event-primary-image").val(1);
  }

  removePreviewImage(elem);

  let files = [...formData.getAll("files[]")];
  formData.delete("files[]");
  files = files.filter((file) => file.name != getFilename(event.images[elem.parent().index()]));
  files.map((file) => formData.append("files[]", file));

  event.images.splice(elem.parent().index(), 1);

  $("#event-primary-image").attr("max", event.images.length);

  elem.parent().remove();
}

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
    addImages($(this));
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this));
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
      $(this).parent().after(`
        <div class="input-field">
          <label for="end-datetime">End date & time</label>
          <input id="end-event-datetime" type="datetime-local" name="end-datetime" required></input>
        </div>
      `);
    } else {
      $(this).parent().next().remove();
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
        data: JSON.stringify(event),
        processData: false,
        contentType: "application/json; charse=UTF-8",
      });

      location.reload();
    } catch {
      endLoadingAnimation($(this));
    }
  });
});
