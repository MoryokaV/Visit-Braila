import { startLoadingAnimation, endLoadingAnimation, phoneRegExp, phoneRegExpTitle, getFilename } from './utils.js';

let paragraph1 = undefined;
let paragraph2 = undefined;

const LIMIT = 500;

let formData = new FormData();
let current_image = undefined;

const appendImageElement = (image, uploaded = false) => {
  $(".img-container").append(
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
}

const addImage = (elem) => {
  if ($(".img-container").children().length > 0) {
    alert("You must have only one cover image!")
    return;
  }

  const file = elem.prop("files")[0];

  formData.append("files[]", file);
  current_image = "/static/media/about/" + file.name;

  appendImageElement(file.name);
}

const removeImage = (elem) => {
  $("#cover-image").prop("required", true);

  formData.delete("files[]");
  current_image = undefined

  elem.parent().remove();
}

$(document).ready(async function() {
  const data = await $.getJSON("/api/fetchAboutData")

  // PARAGRAPHS
  paragraph1 = new Quill("#paragraph-1-content", {
    theme: "snow",
    placeholder: "Type something here...",
  });
  $("#paragraph-1-content .ql-editor").html(data.paragraph1);

  paragraph1.on('text-change', function() {
    if (paragraph1.getLength() > LIMIT) {
      paragraph1.deleteText(LIMIT, paragraph1.getLength());
    }
  });

  paragraph2 = new Quill("#paragraph-2-content", {
    theme: "snow",
    placeholder: "Type something here...",
  });
  $("#paragraph-2-content .ql-editor").html(data.paragraph2);

  paragraph2.on('text-change', function() {
    if (paragraph2.getLength() > LIMIT) {
      paragraph2.deleteText(LIMIT, paragraph2.getLength());
    }
  });

  $("#paragraphs-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    await $.ajax({
      type: "PUT",
      url: "/api/updateAboutParagraphs",
      data: JSON.stringify({ "paragraph1": paragraph1.root.innerHTML, "paragraph2": paragraph2.root.innerHTML }),
      processData: false,
      contentType: "application/json; charset=UTF-8",
    });

    setTimeout(() => endLoadingAnimation($(this)), 400);
  });

  // CONTACT
  $("#director").val(data.director);

  $("#phone").attr("pattern", phoneRegExp).attr("title", phoneRegExpTitle);
  $("#phone").val(data.phone);

  $("#email").val(data.email);

  $("#contact-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    const director = $("#director").val();
    const phone = $("#phone").val();
    const email = $("#email").val();

    await $.ajax({
      type: "PUT",
      url: "/api/updateContactDetails",
      data: JSON.stringify({ "director": director, "phone": phone, "email": email }),
      processData: false,
      contentType: "application/json; charset=UTF-8",
    });

    setTimeout(() => endLoadingAnimation($(this)), 400);
  });

  // COVER IMAGE
  current_image = data.cover_image;
  if (current_image !== "") {
    appendImageElement(current_image, true);
  }

  $("#cover-image").change(function() {
    $(this).prop("required", false);
    addImage($(this));
    $(this).val(null);
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    removeImage($(this));
  });

  $("#cover-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    try {
      await $.ajax({
        type: "POST",
        url: "/api/uploadImages/about",
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
        type: "PUT",
        url: "/api/updateCoverImage",
        data: JSON.stringify({ "cover_image": current_image }),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });

      location.reload();
    } catch {
      endLoadingAnimation($(this));
    }
  });
});
