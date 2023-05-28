import {
  startLoadingAnimation,
  nameRegExp,
  nameRegExpTitle,
  addressRegExp,
  addressRegExpTitle,
  idRegExp,
  idRegExpTitle,
  endLoadingAnimation,
  addImages,
  removeImage,
} from './utils.js';

let quill = undefined;
let formData = new FormData();
let tour = {
  name: "",
  stages: [{ text: "", sight_link: "" }, { text: "", sight_link: "" }],
  description: ``,
  images: [],
  primary_image: 1,
  length: 0,
  external_link: "",
};

const linkInputElement = link => `<input value="${link}" type="text" size="10" class="stage-link form-control text-primary" placeholder="Sight id" pattern="${idRegExp}" title="${idRegExpTitle}" required />`;

const appendStages = () => {
  $("#stages").empty();
  $("#preview-stages").empty();

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
    $("#preview-stages").append(`${$("#preview-stages p").length > 0 ? " &ndash; " : ""}<p class="${stage.sight_link !== "" ? "text-primary text-decoration-underline" : ""}">${stage.text}</p>`);
  });

  $("#stages .stage input").attr("pattern", addressRegExp).attr("title", addressRegExpTitle);
}

$(document).ready(async function() {
  // NAME 
  $("#tour-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);
  $("#tour-name").on('input', function() {
    $("#preview-name").text($(this).val());
  });

  // STAGES
  appendStages(); //two empty required fields

  $("#stages").on('click', ".stage-input-icon", function() {
    const index = $("#stages > div").index($(this).parent());

    if ($(this).hasClass("active")) {
      $(this).removeClass("active");

      //remove sight link
      $(this).parent().next("input").remove();
      tour.stages[index].sight_link = "";
      $("#preview-stages p").eq(index).removeClass("text-decoration-underline text-primary");
    } else {
      $(this).addClass("active");

      //add sight link
      $(this).parent().after(linkInputElement(""));
      $("#preview-stages p").eq(index).addClass("text-decoration-underline text-primary");
    }
  });

  $("#stages").on('click', "#add-stage", function() {
    tour.stages.push({ text: "", sight_link: "" });
    appendStages();
  });

  $("#stages").on('input', ".stage input", function() {
    const index = $("#stages > div").index($(this).parent());
    const stage = $(this).val();

    $(this).attr("size", stage.length);

    tour.stages[index].text = stage;

    $("#preview-stages p").eq(index).text(stage);
  });

  $("#stages").on('keydown', ".stage input", function(e) {
    const index = $("#stages > div").index($(this).parent());

    if (!$(this).val() && index !== 0 && index !== 1 && e.keyCode === 8) {
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

  // DESCRIPTION
  quill = new Quill("#tour-description", {
    theme: "snow",
    placeholder: "Type something here...",
  });

  quill.on('text-change', function() {
    $("#preview-description").html(quill.root.innerHTML);
  });

  // IMAGES
  $("#tour-images").change(function() {
    $(this).prop("required", false);

    addImages($(this).prop('files'), "/static/media/tours/", true, tour.images, formData, $("#tour-primary-image"));

    $(this).val(null);
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), true, tour.images, formData, $("#tour-primary-image"), $("#tour-images"));
  });

  $("#tour-primary-image").on('change', function() {
    $("#preview-primary-image").prop("src", $("#preview-images img").eq($(this).val() - 1).prop("src"));
  });

  // SUBMIT
  $("#insert-tour-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    tour.name = $("#tour-name").val();
    tour.description = quill.root.innerHTML;
    tour.primary_image = parseInt($("#tour-primary-image").val());
    tour.length = parseFloat($("#tour-length").val());
    tour.external_link = $("#tour-external-link").val();

    try {
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

      await $.ajax({
        url: "/api/insertTour",
        type: "POST",
        data: JSON.stringify(tour),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });

      location.reload();
    } catch {
      endLoadingAnimation($(this));
    }
  });
});
