import {
  startLoadingAnimation,
  endLoadingAnimation,
  phoneRegExp,
  phoneRegExpTitle,
  appendImageElement
} from './utils.js';

let paragraph1 = undefined;
let paragraph2 = undefined;

const LIMIT = 500;

let formData = new FormData();
let current_image = undefined;

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
  $("#organization1").val(data.organization1);
  $("#organization2").val(data.organization2);

  $("#phone").attr("pattern", phoneRegExp).attr("title", phoneRegExpTitle);
  $("#phone").val(data.phone);

  $("#email").val(data.email);

  $("#website1").val(data.website1);
  $("#website2").val(data.website2);

  $("#facebook1").val(data.facebook1);
  $("#facebook2").val(data.facebook2);

  $("#contact-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    const organization1 = $("#organization1").val();
    const organization2 = $("#organization2").val();
    const phone = $("#phone").val();
    const email = $("#email").val();
    const website1 = $("#website1").val();
    const website2 = $("#website2").val();
    const facebook1 = $("#facebook1").val();
    const facebook2 = $("#facebook2").val();

    await $.ajax({
      type: "PUT",
      url: "/api/updateContactDetails",
      data: JSON.stringify({ "organization1": organization1, "organization2": organization2, "phone": phone, "email": email, "website1": website1, "website2": website2, "facebook1": facebook1, "facebook2": facebook2 }),
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

    if ($(".img-container").children().length > 0) {
      alert("You must have only one cover image!")
      return;
    }

    const file = $(this).prop("files")[0];

    formData.append("files[]", file);
    current_image = "/static/media/about/" + file.name;

    appendImageElement(file.name);

    $(this).val(null);
  });

  $(".img-container").on("click", ".remove-img-btn", function() {
    $("#cover-image").prop("required", true);

    formData.delete("files[]");
    current_image = undefined

    $(this).parent().remove();
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
