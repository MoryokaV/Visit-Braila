import { startLoadingAnimation, endLoadingAnimation, phoneRegExp, phoneRegExpTitle } from './utils.js';

let paragraph1 = undefined;
const LIMIT = 500;

$(document).ready(async function() {
  // PARAGRAPH
  const paragraph_data = await $.getJSON("/api/fetchAboutParagraph");

  // P1
  paragraph1 = new Quill("#paragraph-1-content", {
    theme: "snow",
    placeholder: "Type something here...",
  });
  $("#paragraph-1-content .ql-editor").html(paragraph_data.content);

  paragraph1.on('text-change', function() {
    if (paragraph1.getLength() > LIMIT) {
      paragraph1.deleteText(LIMIT, paragraph1.getLength());
    }
  });

  $("#paragraph-1-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    await $.ajax({
      type: "PUT",
      url: "/api/updateAboutParagraph",
      data: JSON.stringify({ "content": paragraph1.root.innerHTML }),
      processData: false,
      contentType: "application/json; charset=UTF-8",
    });

    setTimeout(() => endLoadingAnimation($(this)), 400);
  });

  // CONTACT
  const contact_details = await $.getJSON("/api/fetchContactDetails");

  $("#director").val(contact_details.director);

  $("#phone").attr("pattern", phoneRegExp).attr("title", phoneRegExpTitle);
  $("#phone").val(contact_details.phone);

  $("#email").val(contact_details.email);

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
});
