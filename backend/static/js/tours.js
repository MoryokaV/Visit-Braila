import {
  getFilename,
  nameRegExp,
  nameRegExpTitle,
  addressRegExp, 
  addressRegExpTitle,  
} from './utils.js';

let quill = undefined;
let formData = new FormData();
let tour = {
  name: "",
  stages: ["", ""],
  description: ``,
  images: [],
  primary_image: 1,
  route: "",
};

const appendStages = () => {
  $("#stages").empty();
  $("#preview-stages").empty();

  tour.stages.map((stage, index) => {
    $("#stages").append(
      `<input 
        type="text" 
        value="${stage}" 
        size="${stage.length}"
        maxlength="40"
        required /> 
      ${index === tour.stages.length - 1 ? 
        `<button type="button" class="btn text-btn" id="add-stage"> 
          <ion-icon name="add-outline"></ion-icon> 
        </button>`
        :
        `-`
      }`
    );

    $("#preview-stages").append(`${$("#preview-stages p").length > 0 ? " &ndash; " : ""}<p>${stage}</p>`);
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
        <button type="button" class="btn remove-img-btn">
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

  if($("#preview-primary-image").attr("src") === undefined){
    $("#preview-primary-image").prop("src", $("#preview-images img").eq(0).prop("src"));
  }
}

const addImages = (elem) => {
  const images = Array.from(elem.prop('files'));

  addPreviewImages(images); 

  images.map((image) => {
    if(tour.images.includes("tours/" + image.name)){
      alert("Image is already present in list!");
      return;
    }

    formData.append("files[]", image);
    tour.images.push("tours/" + image.name);

    appendImageElement(image.name);
  });

  elem.val(null);
}

const removePreviewImage = (elem) => {
  $("#preview-images img").eq(elem.index()).remove();

  $("#tour-primary-image").change();
}

const removeImage = (elem) => {
  if(tour.images.length === 1){
    alert("Entry must have at least one image.");
    return;
  }

  if(parseInt($("#tour-primary-image").val()) === tour.images.length && elem.index() === tour.images.length - 1){
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
  appendStages();

  $("#stages").on('click', "#add-stage", function() {
    tour.stages.push("");
    appendStages();
  });

  $("#stages").on('input', "input", function() {
    const index = $(this).index();
    const stage = $(this).val();

    $(this).attr("size", stage.length); 

    tour.stages[index] = stage; 
    
    $("#preview-stages p").eq(index).text(stage);
  });

  $("#stages").on('keydown', "input", function(e) {
    const index = $(this).index();

    if(!$(this).val() && index !== 0 && index !== 1 && e.keyCode === 8){
      tour.stages.splice(index, 1);
      appendStages();

      return;
    }
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
      success: function(data) {
        console.log(data);
      }
    });

    await $.ajax({
      url: "/api/insertTour",
      type: "POST",
      data: JSON.stringify(tour),
      processData: false,
      contentType: "application/json; charset=UTF-8",
      success: function(data) {
        console.log(data);
      }
    });

    location.reload();
  });
});
