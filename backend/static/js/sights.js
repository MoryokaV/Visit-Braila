import {
  startLoadingAnimation,
  nameRegExp,
  nameRegExpTitle,
  longitudeRegExp,
  latitudeRegExp,
  latitudeRegExpTitle,
  longitudeRegExpTitle,
  endLoadingAnimation,
  addImages,
  removeImage,
  initializeTags,
} from './utils.js';

let quill = undefined;
let formData = new FormData();
let sight = {
  name: "",
  tags: [],
  description: ``,
  images: [],
  primary_image: 1,
  latitude: "",
  longitude: "",
  external_link: "",
};

$(document).ready(async function() {
  // NAME
  $("#sight-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);
  $("#sight-name").on('input', function() {
    $("#preview-name").text($(this).val());
  });

  // TAGS
  await initializeTags("sights", sight.tags, true, "");

  // DESCRIPTION
  quill = new Quill("#sight-description", {
    theme: "snow",
  });

  quill.on('text-change', function() {
    $("#preview-description").html(quill.root.innerHTML);
  });

  // IMAGES 
  $("#sight-images").change(function() {
    $(this).prop("required", false);

    addImages($(this).prop('files'), "/static/media/sights/", true, sight.images, formData, $("#sight-primary-image"));

    $(this).val(null);
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), true, sight.images, formData, $("#sight-primary-image"), $("#sight-images"));
  });

  $("#sight-primary-image").on('change', function() {
    $("#preview-primary-image").prop("src", $("#preview-images img").eq($(this).val() - 1).prop("src"));
  });

  // COORDINATES
  $("#sight-latitude").attr("pattern", latitudeRegExp).attr("title", latitudeRegExpTitle);
  $("#sight-longitude").attr("pattern", longitudeRegExp).attr("title", longitudeRegExpTitle);


  // SUBMIT
  $("#insert-sight-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    sight.name = $("#sight-name").val();
    sight.description = quill.root.innerHTML;
    sight.primary_image = parseInt($("#sight-primary-image").val());
    sight.latitude = parseFloat($("#sight-latitude").val());
    sight.longitude = parseFloat($("#sight-longitude").val());
    sight.external_link = $("#sight-external-link").val();

    try {
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

      await $.ajax({
        url: "/api/insertSight",
        type: "POST",
        data: JSON.stringify(sight),
        processData: false,
        contentType: "application/json; charse=UTF-8",
      });

      location.reload();
    } catch {
      endLoadingAnimation($(this));
    }
  });
});
