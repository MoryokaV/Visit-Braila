import { 
  getFilename,
  nameRegExp,
  nameRegExpTitle
} from './utils.js';

let quill = undefined;
let formData = new FormData();
let sight = {
  name: "",
  tags: [],
  description: ``,
  images: [],
  primary_image: 1,
  positoin: "",
};

const appendActiveTags = () => {
  $("#active-tags").empty()
  sight.tags.map((tag) => $("#active-tags").append(`<p class="tag-item">${tag}</p>`));
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

  $("#sight-primary-image").attr("max", sight.images.length);
}

const addImage = (elem) => {
  Array.from(elem.prop('files')).map((image) => {
    if(sight.images.includes("sights/" + image.name)){
      alert("Image is already present in list!");
      return;
    }

    formData.append("files[]", image);
    sight.images.push("sights/" + image.name);

    appendImageElement(image.name);
  });

  elem.val(null);
}

const removeImage = (elem) => {
  if(sight.images.length === 1){
    alert("Entry must have at least one image.");
    return;
  }

  let files = [...formData.getAll("files[]")];
  formData.delete("files[]");
  files = files.filter((file) => file.name != getFilename(sight.images[elem.parent().index()]));
  files.map((file) => formData.append("files[]", file));

  sight.images.splice(elem.parent().index(), 1);

  $("#sight-primary-image").attr("max", sight.images.length);

  elem.parent().remove();
}

$(document).ready(async function() {
  // NAME
  $("#sight-name").attr("pattern", nameRegExp).attr("title", nameRegExpTitle);

  // TAGS
  const tags = await $.getJSON("/api/fetchTags");
  tags.map((tag) => $("#tags").append(`<option value="${tag.name}">${tag.name}</option>`));

  // DESCRIPTION
  quill = new Quill("#sight-description", {
    theme: "snow",
  });
  
  // IMAGES 
  $('#sight-images').change(function() {
    addImage($(this));
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this));
  });

  // TAGS
  $("#tags").change(function() {
    if(!sight.tags.includes($(this).val())){
      $("#tag-btn")
        .removeClass("danger")
        .text("Add")
        .off("click")
        .click(function() {
          if(sight.tags.length === 3){
            alert("You cannot use more than 3 tags!");
            return;
          }

          sight.tags.push($("#tags").val());

          appendActiveTags();

          $(this).off("click");
          $("#tags").val("-");
        });
    }else{
      $("#tag-btn")
        .addClass("danger")
        .text("Remove")
        .off("click")
        .click(function() {
          const index = sight.tags.indexOf($("#tags").val());
          sight.tags.splice(index, 1);

          appendActiveTags();

          $(this).removeClass("danger").text("Add").off("click");
          $("#tags").val("-");
        });
    }
  });

  $("#insert-sight-form").submit(async function(e) {
    e.preventDefault();

    sight.name = $("#sight-name").val(); 
    sight.description = quill.root.innerHTML;
    sight.primary_image = $("#sight-primary-image").val();
    sight.position = $("#sight-position").val();
  
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

    await $.ajax({
      url: "/api/insertSight",
      type: "POST",
      data: JSON.stringify(sight),
      processData: false,
      contentType: "application/json; charse=UTF-8",
      success: function(data) {
        console.log(data); 
      }
    });

    location.reload(); 
  }); 
});
