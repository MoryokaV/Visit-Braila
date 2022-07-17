import { fetchSights, tags } from './dashboard.js'

let sight = {};
let current_images = [];
let formData = undefined;
let images_to_delete = [];
let quill = undefined;

const closeModal = () => {
  $(".ql-toolbar").remove();
  $(".modal").removeClass("show");  
}

const getFilename = image => image.substring(image.lastIndexOf('/') + 1);

const appendSightImage = (image, uploaded = false, index) => {
  $("#sight-modal .img-container").append(
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

  $("#sight-modal #primary-image").attr("max", current_images.length);
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
  $("#sight-modal #name").val(sight.name);
  
  // TAGS
  appendActiveTags();

  $('#sight-modal #tags option:gt(1)').remove()
  tags.map((tag) => $("#sight-modal #tags").append(`<option value="${tag}">${tag}</option>`));
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
  
  // DESCRIPTION
  $("#sight-modal #description").html(sight.description)
  quill = new Quill("#sight-modal #description", {
    theme: "snow",
  });

  // IMAGES
  $("#sight-modal .img-container").empty()
  sight.images.map((image) => appendSightImage(image, true));

  $("#sight-modal #primary-image").val(sight.primary_image);

  $('#sight-modal #images').change(function() {
    Array.from($(this).prop('files')).map((image) => {
      if(current_images.includes("sights/" + image.name)){
        alert("Image is already present in list!");
        return;
      }

      formData.append("files[]", image);
      current_images.push("sights/" + image.name);

      appendSightImage("sights/" + image.name);
    });

    $(this).val(null)
  });
  
  // POSITION
  $("#sight-modal #position").val(sight.position) 
}

$(document).ready(async function () {
  $(".close-btn").click(closeModal);

  // SIGHT IMAGES 
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
    
    $("#sight-modal #primary-image").attr("max", current_images.length);
    
    $(this).parent().remove();
  });

  // SUBMIT
  $("#sight-modal form").submit(async function (e) {
    e.preventDefault();

    sight.name = $("#sight-modal #name").val();
    sight.description = quill.root.innerHTML;
    sight.primary_image = $("#sight-modal #primary-image").val();
    sight.position = $("#sight-modal #position").val();

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
});
