import {
  getFilename,
  startLoadingAnimation,
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
  external_link: "",
};

const appendActiveTags = () => {
  $("#active-tags").empty();
  $("#preview-tags").empty();

  sight.tags.map((tag, index) => {
    $("#active-tags").append(`<p class="tag-item">${tag}</p>`);
    $("#preview-tags").append(`<p>${tag}</p>${index != sight.tags.length - 1 ? ", " : " "}`)
  });
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

  $("#sight-primary-image").attr("max", sight.images.length);
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
    if (sight.images.includes("/static/media/sights/" + image.name)) {
      alert(`'${image.name}' is already present in list!`);
      return false;
    }

    return true;
  });

  addPreviewImages(images);

  images.map((image) => {
    formData.append("files[]", image);
    sight.images.push("/static/media/sights/" + image.name);

    appendImageElement(image.name);
  });

  elem.val(null);
}

const removePreviewImage = (elem) => {
  $("#preview-images img").eq(elem.parent().index()).remove();

  $("#sight-primary-image").change();
}

const removeImage = (elem) => {
  if (sight.images.length === 1) {
    alert("Entry must have at least one image.");
    return;
  }

  if (parseInt($("#sight-primary-image").val()) === sight.images.length) {
    $("#sight-primary-image").val(sight.images.length - 1);
  }

  removePreviewImage(elem);

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
  $("#sight-name").on('input', function() {
    $("#preview-name").text($(this).val());
  });

  // TAGS
  const tags = await $.getJSON("/api/fetchTags");
  tags.map((tag) => $("#tags").append(`<option value="${tag.name}">${tag.name}</option>`));

  $("#tags").change(function() {
    if (!sight.tags.includes($(this).val())) {
      $("#tag-btn")
        .removeClass("danger")
        .text("Add")
        .off("click")
        .click(function() {
          if (sight.tags.length === 3) {
            alert("You cannot use more than 3 tags!");
            return;
          }

          sight.tags.push($("#tags").val());

          appendActiveTags();

          $(this).off("click");
          $("#tags").val("-");
        });
    } else {
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
    addImages($(this));
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this));
  });

  $("#sight-primary-image").on('change', function() {
    $("#preview-primary-image").prop("src", $("#preview-images img").eq($(this).val() - 1).prop("src"));
  });

  // SUBMIT
  $("#insert-sight-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    sight.name = $("#sight-name").val();
    sight.description = quill.root.innerHTML;
    sight.primary_image = parseInt($("#sight-primary-image").val());
    sight.external_link = $("#sight-external-link").val();

    await $.ajax({
      type: "POST",
      url: "/api/uploadImages/sights",
      contentType: false,
      data: formData,
      cache: false,
      processData: false,
    });

    await $.ajax({
      url: "/api/insertSight",
      type: "POST",
      data: JSON.stringify(sight),
      processData: false,
      contentType: "application/json; charse=UTF-8",
    });

    location.reload();
  });
});
