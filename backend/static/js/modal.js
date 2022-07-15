import { fetchSights } from './scripts.js'

let sight = {};
let quill = undefined;
let current_images = [];
let formData = undefined;
let images_to_delete = [];

const closeModal = () => {
  $(".ql-toolbar").remove();
  $("#description").removeClass("ql-container ql-snow");

  $(".modal").removeClass("show");  
}

const getFilename = image => image.substring(image.lastIndexOf('/') + 1);

const appendSightImage = (image) => {
  $(".img-container").append(
      `<li class="img-preview">
        <a href="../static/media/${image}" class="group">
          <ion-icon name="image-outline"></ion-icon>
          ${getFilename(image)}
        </a>
        <button type="button" class="btn remove-img-btn">
          <ion-icon name="close-outline"></ion-icon>
        </button>
      </li>`
    ); 
}

export const openUpdateModal = async (id) => {
  sight = await $.getJSON(window.origin + "/api/findSight/" + id);
  current_images = [...sight.images];
  formData = new FormData();
  images_to_delete = [];

  // NAME
  $("#name").val(sight.name);
  
  // TAGS
  $("#active-tags").empty()
  sight.tags.map((tag) => $("#active-tags").append(`<p class="tag-item">${tag}</p>`));
  //TODO: get tags for <option>

  // DESCRIPTION
  $("#description").html(sight.description)
  quill = new Quill("#description", {
    theme: "snow",
  });

  // IMAGES
  $(".img-container").empty()
  sight.images.map((image) => appendSightImage(image));

  $('#images').change(function() {
    const new_images = $("#images").prop('files');

    Array.from(new_images).map((image) => {
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
  $("#position").val(sight.position) 
}

$(document).ready(async function () {
  $(".close-btn").click(closeModal);

  // IMAGES 
  $(".img-container").on("click", ".remove-img-btn", function (e) {
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
    
    $(this).parent().remove();
  });

  // SUBMIT
  $(".modal-body form").submit(async function (e) {
    e.preventDefault();

    sight.name = $("#name").val();
    sight.description = quill.root.innerHTML;
    sight.position = $("#position").val();

    if(images_to_delete.length > 0)
      $.ajax({
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
      $.ajax({
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
      url: "/api/updateSight/" + sight._id,
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
