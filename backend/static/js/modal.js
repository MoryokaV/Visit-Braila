import { fetchSights, fetchTours } from './dashboard.js';
import { 
  getFilename, 
  startLoadingAnimation,
  endLoadingAnimation,
  nameRegExp, 
  nameRegExpTitle,
  addressRegExp, 
  addressRegExpTitle,  
} from './utils.js';

let sight = {};
let tour = {};
let current_images = [];
let formData = undefined;
let images_to_delete = [];
let quill = undefined;

const closeModal = () => {
  $(".modal").removeClass("show");  
  $(".ql-toolbar").remove();
}

const addImage = (folder, elem, modal) => {
  Array.from(elem.prop('files')).map((image) => {
    if(current_images.includes(`/static/media/${folder}/${image.name}`)){
      alert(`'${image.name}' is already present in list!`);
      return;
    }

    formData.append("files[]", image);
    current_images.push("/static/media/" + folder + "/" + image.name);

    appendImageElement(folder + "/" + image.name, modal);
  });

  elem.val(null)
}

const removeImage = (elem, modal) => {
  if(current_images.length === 1){
    alert("Entry must have at least one image.");
    return;
  }

  if(parseInt($(`#${modal}-primary-image`).val()) === current_images.length){
    $(`#${modal}-primary-image`).val(current_images.length - 1);    
  }

  //clean up FormData
  let files = [...formData.getAll("files[]")];
  formData.delete("files[]");
  files = files.filter((file) => file.name !== getFilename(current_images[elem.parent().index()]));
  files.map((file) => formData.append("files[]", file)); 

  //mark for deletion
  const savedImages = modal === "sight" ? sight.images : tour.images;
  if(savedImages.includes(current_images[elem.parent().index()])){
    images_to_delete.push(current_images[elem.parent().index()]);
  }

  current_images.splice(elem.parent().index(), 1)
  
  $(`#${modal}-primary-image`).attr("max", current_images.length);
  
  elem.parent().remove();
}

const appendImageElement = (image, modal_name, uploaded = false) => {
  $(`#${modal_name}-modal .img-container`).append(
      `<li class="highlight-onhover">
        <a ${uploaded ? `href="${image}" target="_blank"` : ``} class="group">
          ${uploaded ? `<ion-icon name="image-outline"></ion-icon>` : `<ion-icon name="cloud-upload-outline"></ion-icon>`}
          ${getFilename(image)}
        </a>
        <button type="button" class="btn icon-btn remove-img-btn">
          <ion-icon name="close-outline"></ion-icon>
        </button>
      </li>`
    );

  $(`#${modal_name}-modal #${modal_name}-primary-image`).attr("max", current_images.length);
}

const appendActiveTags = () => {
  $("#sight-modal #active-tags").empty()
  sight.tags.map((tag) => $("#sight-modal #active-tags").append(`<p class="tag-item">${tag}</p>`));
}

const appendStages = () => {
  $("#tour-modal #stages").empty();

  tour.stages.map((stage, index) => {
    $("#tour-modal #stages").append(
      `<input 
        type="text" 
        value="${stage}" 
        size="${stage.length}"
        maxlength="40"
        required /> 
      ${index === tour.stages.length - 1 ? 
        `<button type="button" class="btn icon-btn" id="add-stage" style="color: var(--primary-color)"> 
          <ion-icon name="add-outline"></ion-icon> 
        </button>`
        :
        `-`
      }`
    );
  });

  $("#tour-modal #stages input").attr("pattern", addressRegExp).attr("title", addressRegExpTitle);
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
  $("#sight-modal .img-container").empty()
  sight.images.map((image) => appendImageElement(image, "sight", true));

  $("#sight-primary-image").val(sight.primary_image);

  // POSITION
  $("#sight-position").val(sight.position) 
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
  $("#tour-modal .img-container").empty()
  tour.images.map((image) => appendImageElement(image, "tour", true));

  $("#tour-primary-image").val(tour.primary_image);

  // ROUTE 
  $("#tour-route").val(tour.route);
}

$(document).ready(async function () {
  $(".close-btn").click(closeModal);

  // SIGHT NAME
  $("#sight-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);

  // SIGHT TAGS
  $("#sight-modal #tags").change(function() {
    if(!sight.tags.includes($(this).val())){
      $("#sight-modal #tag-btn")
        .removeClass("danger")
        .text("Add")
        .off("click")
        .click(function() {
          if(sight.tags.length === 3){
            alert("You cannot use more than 3 tags!");
            return;
          }

          sight.tags.push($("#sight-modal #tags").val());

          appendActiveTags();

          $(this).off("click");
          $("#sight-modal #tags").val("-");
        });
    }else{
      $("#sight-modal #tag-btn")
        .addClass("danger")
        .text("Remove")
        .off("click")
        .click(function() {
          const index = sight.tags.indexOf($("#sight-modal #tags").val());
          sight.tags.splice(index, 1);

          appendActiveTags();

          $(this).removeClass("danger").text("Add").off("click");
          $("#sight-modal #tags").val("-");
        });
    }
  });

  // SIGHT IMAGES 
  $('#sight-images').change(function() {
    addImage("sights", $(this), "sight");
  });

  $("#sight-modal .img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), "sight"); 
  });

  // SIGHT SUBMIT
  $("#sight-modal form").submit(async function (e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    sight.name = $("#sight-name").val();
    sight.description = quill.root.innerHTML;
    sight.primary_image = $("#sight-primary-image").val();
    sight.position = $("#sight-position").val();

    if(formData.getAll("files[]").length > 0)
      await $.ajax({
        type: "POST",
        url: "/api/uploadImages/sights",
        contentType: false,
        data: formData,
        cache: false,
        processData: false,
      });

    sight.images = [...current_images];

    await $.ajax({
      url: "/api/editSight",
      type: "PUT",
      data: JSON.stringify({"images_to_delete": images_to_delete, "sight": sight}),
      processData: false,
      contentType: "application/json; charset=UTF-8",
    });
    
    await fetchSights();
    closeModal();
    endLoadingAnimation($(this));
  });

  // TOUR NAME
  $("#tour-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);
  
  // TOUR STAGES
  $("#tour-modal #stages").on('click', "#add-stage", function() {
    tour.stages.push(""); 
    appendStages();
  });

  $("#tour-modal #stages").on('input', "input", function() {
    $(this).attr("size", $(this).val().length); 

    tour.stages[$(this).index()] = $(this).val();
  });

  $("#tour-modal #stages").on('keydown', "input", function(e) {
    const index = $(this).index();

    if($(this).val() === "" && index !== 0 && index !== 1 && e.keyCode === 8){
      tour.stages.splice(index, 1);
      appendStages();

      return;
    }
  });

  // TOUR IMAGES 
  $('#tour-images').change(function() {
    addImage("tours", $(this), "tour"); 
  });

  $("#tour-modal .img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this), "tour");
  });

  // TOUR SUBMIT 
  $("#tour-modal form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    tour.name = $("#tour-name").val();
    tour.description = quill.root.innerHTML;
    tour.primary_image = $("#tour-primary-image").val();
    tour.route = $("#tour-route").val();
    
    if(formData.getAll("files[]").length > 0)
      await $.ajax({
        type: "POST",
        url: "/api/uploadImages/tours",
        contentType: false,
        data: formData,
        cache: false,
        processData: false,
      });

    tour.images = [...current_images];

    await $.ajax({
      url: "/api/editTour",
      type: "PUT",
      data: JSON.stringify({"images_to_delete": images_to_delete, "tour": tour}),
      processData: false,
      contentType: "application/json; charset=UTF-8",
    });
  
    await fetchTours();
    closeModal();
    endLoadingAnimation($(this));
  });
});
