import { fetchSights, tags, fetchTours } from './dashboard.js'

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

const getFilename = image => image.substring(image.lastIndexOf('/') + 1);

const appendImageElement = (image, modal_name, uploaded = false) => {
  $(`#${modal_name}-modal .img-container`).append(
      `<li class="img-preview">
        <a ${uploaded ? `href="../static/media/${image}" target="_blank"` : ``} class="group">
          ${uploaded ? `<ion-icon name="image-outline"></ion-icon>` : `<ion-icon name="cloud-upload-outline"></ion-icon>`}
          ${getFilename(image)}
        </a>
        <button type="button" class="btn remove-img-btn">
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

export const openEditSightModal = async (id) => {
  sight = await $.getJSON("/api/findSight/" + id);
  current_images = [...sight.images];
  formData = new FormData();
  images_to_delete = [];

  // NAME
  $("#sight-name").val(sight.name);
  
  // TAGS
  appendActiveTags();

  $('#sight-modal #tags option:gt(1)').remove()
  tags.map((tag) => $("#sight-modal #tags").append(`<option value="${tag}">${tag}</option>`));
  
  // DESCRIPTION
  $("#sight-description").html(sight.description)
  quill = new Quill("#sight-description", {
    theme: "snow",
  });

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
  
  // DESCRIPTION
  $("#tour-description").html(tour.description);
  quill = new Quill("#tour-description", {
    theme: "snow",
  });

  // IMAGES
  $("#tour-modal .img-container").empty()
  tour.images.map((image) => appendImageElement(image, "tour", true));

  $("#tour-primary-image").val(tour.primary_image);

  // ROUTE 
  $("#tour-route").val(tour.route);
}

$(document).ready(async function () {
  $(".close-btn").click(closeModal);

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
    Array.from($(this).prop('files')).map((image) => {
      if(current_images.includes("sights/" + image.name)){
        alert("Image is already present in list!");
        return;
      }

      formData.append("files[]", image);
      current_images.push("sights/" + image.name);

      appendImageElement("sights/" + image.name, "sight");
    });

    $(this).val(null)
  });

  $("#sight-modal .img-container").on("click", ".remove-img-btn", function (e) {
    if(current_images.length === 1){
      alert("Entry must have at least one image.");
      return;
    }

    //clean up FormData
    let files = [...formData.getAll("files[]")];
    formData.delete("files[]");
    files = files.filter((file) => file.name !== getFilename(current_images[$(this).parent().index()]));
    files.map((file) => formData.append("files[]", file)); 

    //mark for deletion
    if(sight.images.includes(current_images[$(this).parent().index()])){
      images_to_delete.push(getFilename(current_images[$(this).parent().index()]));
    }

    current_images.splice($(this).parent().index(), 1)
    
    $("#sight-primary-image").attr("max", current_images.length);
    
    $(this).parent().remove();
  });

  // SIGHT SUBMIT
  $("#sight-modal form").submit(async function (e) {
    e.preventDefault();

    sight.name = $("#sight-name").val();
    sight.description = quill.root.innerHTML;
    sight.primary_image = $("#sight-primary-image").val();
    sight.position = $("#sight-position").val();

    if(images_to_delete.length > 0)
      await $.ajax({
        url: "/api/deleteImages/sights",
        type: "DELETE",
        data: JSON.stringify({"images": images_to_delete}),
        processData: false,
        contentType: "application/json; charset=UTF-8",
        success: function(data) {
          console.log(data);
        }
      });

    if(formData.getAll("files[]").length > 0)
      await $.ajax({
        type: "POST",
        url: "/api/uploadImages/sights",
        contentType: false,
        data: formData,
        cache: false,
        processData: false,
        success: function(data) {
          console.log(data);
        }
      });

    sight.images = [...current_images];

    await $.ajax({
      url: "/api/editSight/" + sight._id,
      type: "PUT",
      data: JSON.stringify(sight),
      processData: false,
      contentType: "application/json; charset=UTF-8",
      success: function(data) {
        console.log(data);
      }
    });

    await fetchSights();
    closeModal();
  });
  
  // TOUR IMAGES 
  $('#tour-images').change(function() {
    Array.from($(this).prop('files')).map((image) => {
      if(current_images.includes("tours/" + image.name)){
        alert("Image is already present in list!");
        return;
      }
      
      formData.append("files[]", image);
      current_images.push("tours/" + image.name);

      appendImageElement("tours/" + image.name, "tour");
    });

    $(this).val(null)
  });

  $("#tour-modal .img-container").on("click", ".remove-img-btn", function (e) {
    if(current_images.length === 1){
      alert("Entry must have at least one image.");
      return;
    }

    //clean up FormData
    let files = [...formData.getAll("files[]")];
    formData.delete("files[]");
    files = files.filter((file) => file.name !== getFilename(current_images[$(this).parent().index()]));
    files.map((file) => formData.append("files[]", file)); 

    //mark for deletion
    if(tour.images.includes(current_images[$(this).parent().index()])){
      images_to_delete.push(getFilename(current_images[$(this).parent().index()]));
    }

    current_images.splice($(this).parent().index(), 1)
    
    $("#tour-primary-image").attr("max", current_images.length);
    
    $(this).parent().remove();
  });

  $("#tour-modal form").submit(async function(e) {
    e.preventDefault();

    tour.name = $("#tour-name").val();
    tour.description = quill.root.innerHTML;
    tour.primary_image = $("#tour-primary-image").val();
    tour.route = $("#tour-route").val();

    if(images_to_delete.length > 0)
      await $.ajax({
        url: "/api/deleteImages/tours",
        type: "DELETE",
        data: JSON.stringify({"images": images_to_delete}),
        processData: false,
        contentType: "application/json; charset=UTF-8",
        success: function(data) {
          console.log(data);
        }
      });
    
    if(formData.getAll("files[]").length > 0)
      await $.ajax({
        type: "POST",
        url: "/api/uploadImages/tours",
        contentType: false,
        data: formData,
        cache: false,
        processData: false,
        success: function(data) {
          console.log(data);
        }
      });

    tour.images = [...current_images];

    await $.ajax({
      url: "/api/editTour/" + tour._id,
      type: "PUT",
      data: JSON.stringify(tour),
      processData: false,
      contentType: "application/json; charset=UTF-8",
      success: function(data) {
        console.log(data);
      }
    });

    await fetchTours();
    closeModal();
  });
});
