import {
  getFilename,
  startLoadingAnimation,
  nameRegExp,
  nameRegExpTitle,
  addressRegExp,
  addressRegExpTitle,
} from './utils.js';

let quill = undefined;
let formData = new FormData();
let tour = {
  name: "",
  stages: [{ text: "", sight_link: "" }, { text: "", sight_link: "" }],
  description: ``,
  images: [],
  primary_image: 1,
  route: "",
};

const linkInputElement = link => `<input value="${link}" type="text" size="10" class="stage-link" placeholder="Sight id" required />`;

const appendStages = () => {
  $("#stages").empty();
  $("#preview-stages").empty();

  tour.stages.map((stage, index) => {
    $("#stages").append(
      `<div class="stage">
        <input type="text" value="${stage.text}" size="${stage.text.length}" maxlength="40" required /> 
        <ion-icon name="link-outline" class="stage-input-icon ${stage.sight_link !== "" ? "active" : ""}"></ion-icon>
      </div>
      ${stage.sight_link !== "" ? linkInputElement(stage.sight_link) : ``}
      ${index === tour.stages.length - 1 ?
        `<button type="button" class="btn icon-btn link" id="add-stage"> 
          <ion-icon name="add-outline"></ion-icon> 
        </button>`
        :
        `-`
      }`
    );

    $("#preview-stages").append(`${$("#preview-stages p").length > 0 ? " &ndash; " : ""}<p class="${stage.sight_link !== "" ? "hyperlink" : ""}">${stage.text}</p>`);
  });

  $("#stages input").attr("pattern", addressRegExp).attr("title", addressRegExpTitle);
}

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

  $("#tour-primary-image").attr("max", tour.images.length);
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
    if (tour.images.includes("/static/media/tours/" + image.name)) {
      alert(`'${image.name}' is already present in list!`);
      return false;
    }

    return true;
  });

  addPreviewImages(images);

  images.map((image) => {
    formData.append("files[]", image);
    tour.images.push("/static/media/tours/" + image.name);

    appendImageElement(image.name);
  });

  elem.val(null);
}

const removePreviewImage = (elem) => {
  $("#preview-images img").eq(elem.parent().index()).remove();

  $("#tour-primary-image").change();
}

const removeImage = (elem) => {
  if (tour.images.length === 1) {
    alert("Entry must have at least one image.");
    return;
  }

  if (parseInt($("#tour-primary-image").val()) === tour.images.length) {
    $("#tour-primary-image").val(tour.images.length - 1);
  }

  removePreviewImage(elem);

  let files = [...formData.getAll("files[]")];
  formData.delete("files[]");
  files = files.filter((file) => file.name != getFilename(tour.images[elem.parent().index()]));
  files.map((file) => formData.append("files[]", file));

  tour.images.splice(elem.parent().index(), 1);

  $("#tour-primary-image").attr("max", tour.images.length);

  elem.parent().remove();
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
      $("#preview-stages p").eq(index).removeClass("hyperlink");
    } else {
      $(this).addClass("active");

      //add sight link
      $(this).parent().after(linkInputElement(""));
      $("#preview-stages p").eq(index).addClass("hyperlink");
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
  });

  quill.on('text-change', function() {
    $("#preview-description").html(quill.root.innerHTML);
  });

  // IMAGES
  $("#tour-images").change(function() {
    $(this).prop("required", false);
    addImages($(this));
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this));
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
    tour.primary_image = $("#tour-primary-image").val();
    tour.route = $("#tour-route").val();

    await $.ajax({
      type: "POST",
      url: "/api/uploadImages/tours",
      contentType: false,
      data: formData,
      cache: false,
      processData: false,
    });

    await $.ajax({
      url: "/api/insertTour",
      type: "POST",
      data: JSON.stringify(tour),
      processData: false,
      contentType: "application/json; charset=UTF-8",
    });

    location.reload();
  });
});
