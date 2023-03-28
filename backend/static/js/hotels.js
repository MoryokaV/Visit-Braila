import {
  initializeTags,
  nameRegExp,
  nameRegExpTitle,
  phoneRegExp,
  phoneRegExpTitle,
  addImages,
  removeImage,
  latitudeRegExp,
  latitudeRegExpTitle,
  longitudeRegExp,
  longitudeRegExpTitle,
  startLoadingAnimation,
  endLoadingAnimation,
} from "./utils.js";

let quill = undefined;

let formData = new FormData();
let hotel = {
  name: "",
  stars: 1,
  phone: "",
  tags: [],
  description: ``,
  images: [],
  primary_image: 1,
  latitude: "",
  longitude: "",
  external_link: "",
};

const getPreviewStarsElem = () => {
  return `<span id="preview-stars" class="stars">${"★".repeat(hotel.stars)}</span>`;
}

$(document).ready(async function() {
  // NAME
  $("#hotel-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);
  $("#hotel-name").on('input', function() {
    if ($(this).val() === "") {
      $("#preview-name").html($(this).val());
    } else {
      $("#preview-name").html($(this).val() + getPreviewStarsElem());
    }
  });

  // STARS
  $("#hotel-stars").change(function() {
    hotel.stars = parseInt($(this).val());

    if (hotel.stars > 5) {
      hotel.stars = 5;
    } else if (hotel.stars < 1) {
      hotel.stars = 1;
    }

    $(this).val(hotel.stars);

    $("#preview-stars").text("★".repeat(parseInt($(this).val())));
  });

  // PHONE
  $("#hotel-phone").attr("pattern", phoneRegExp).attr("title", phoneRegExpTitle);

  // TAGS
  await initializeTags("hotels", hotel.tags, true, "");

  // DESCRIPTION
  quill = new Quill("#hotel-description", {
    theme: "snow",
  });

  quill.on('text-change', function() {
    $("#preview-description").html(quill.root.innerHTML);
  });

  // IMAGES
  $("#hotel-images").change(function() {
    $(this).prop("required", false);

    addImages($(this).prop('files'), "/static/media/hotels/", true, hotel.images, formData, $("#hotel-primary-image"));

    $(this).val(null);
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), true, hotel.images, formData, $("#hotel-primary-image"), $("#hotel-images"))
  });

  $("#hotel-primary-image").on('change', function() {
    $("#preview-primary-image").prop("src", $("#preview-images img").eq($(this).val() - 1).prop("src"));
  });

  // COORDINATES 
  $("#hotel-latitude").attr("pattern", latitudeRegExp).attr("title", latitudeRegExpTitle);
  $("#hotel-longitude").attr("pattern", longitudeRegExp).attr("title", longitudeRegExpTitle);

  // SUBMIT
  $("#insert-hotel-form").submit(async function(e) {
    e.preventDefault();

    if (hotel.tags.length === 0) {
      alert("Use at least one tag!");
      return false;
    }

    startLoadingAnimation($(this));

    hotel.name = $("#hotel-name").val();
    hotel.phone = $("#hotel-phone").val();
    hotel.description = quill.root.innerHTML;
    hotel.primary_image = parseInt($("#hotel-primary-image").val());
    hotel.latitude = parseFloat($("#hotel-latitude").val());
    hotel.longitude = parseFloat($("#hotel-longitude").val());
    hotel.external_link = $("#hotel-external-link").val();


    try {
      await $.ajax({
        type: "POST",
        url: "/api/uploadImages/hotels",
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
        url: "/api/insertHotel",
        type: "POST",
        data: JSON.stringify(hotel),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });

      location.reload();
    } catch {
      endLoadingAnimation($(this));
    }
  });
});
