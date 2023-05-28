import { nameRegExp, latitudeRegExp, longitudeRegExp, nameRegExpTitle, latitudeRegExpTitle, longitudeRegExpTitle, addImages, startLoadingAnimation, endLoadingAnimation, removeImage, initializeTags } from './utils.js';

let quill = undefined;
let formData = new FormData();
let restaurant = {
  name: "",
  tags: [],
  description: ``,
  images: [],
  primary_image: 1,
  latitude: "",
  longitude: "",
  external_link: "",
}

$(document).ready(async function() {
  // NAME
  $("#restaurant-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);
  $("#restaurant-name").on('input', function() {
    $("#preview-name").text($(this).val());
  });

  // TAGS
  await initializeTags("restaurants", restaurant.tags, true, "");

  // DESCRIPTION
  quill = new Quill("#restaurant-description", {
    theme: "snow",
    placeholder: "Type something here...",
  });

  quill.on('text-change', function() {
    $("#preview-description").html(quill.root.innerHTML);
  });

  // IMAGES
  $("#restaurant-images").change(function() {
    $(this).prop("required", false);

    addImages($(this).prop('files'), "/static/media/restaurants/", true, restaurant.images, formData, $("#restaurant-primary-image"));

    $(this).val(null);
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), true, restaurant.images, formData, $("#restaurant-primary-image"), $("#restaurant-images"))
  });

  $("#restaurant-primary-image").on('change', function() {
    $("#preview-primary-image").prop("src", $("#preview-images img").eq($(this).val() - 1).prop("src"));
  });

  // COORDINATES 
  $("#restaurant-latitude").attr("pattern", latitudeRegExp).attr("title", latitudeRegExpTitle);
  $("#restaurant-longitude").attr("pattern", longitudeRegExp).attr("title", longitudeRegExpTitle);

  // SUBMIT
  $("#insert-restaurant-form").submit(async function(e) {
    e.preventDefault();

    if (restaurant.tags.length === 0) {
      alert("Use at least one tag!");
      return false;
    }

    startLoadingAnimation($(this));

    restaurant.name = $("#restaurant-name").val();
    restaurant.description = quill.root.innerHTML;
    restaurant.primary_image = parseInt($("#restaurant-primary-image").val());
    restaurant.latitude = parseFloat($("#restaurant-latitude").val());
    restaurant.longitude = parseFloat($("#restaurant-longitude").val());
    restaurant.external_link = $("#restaurant-external-link").val();

    try {
      await $.ajax({
        type: "POST",
        url: "/api/uploadImages/restaurants",
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
        url: "/api/insertRestaurant",
        type: "POST",
        data: JSON.stringify(restaurant),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });

      location.reload();
    } catch {
      endLoadingAnimation($(this));
    }
  });

});
