import { startLoadingAnimation, endLoadingAnimation, phoneRegExp, phoneRegExpTitle } from './utils.js';

let paragraph1 = undefined;
let paragraph2 = undefined;

const LIMIT = 500;

$(document).ready(async function() {
  // PARAGRAPHS
  const paragraph1_data = await $.getJSON("/api/fetchAboutParagraph1");
  const paragraph2_data = await $.getJSON("/api/fetchAboutParagraph2");

  // P1
  paragraph1 = new Quill("#paragraph-1-content", {
    theme: "snow",
    placeholder: "Type something here...",
  });
  $("#paragraph-1-content .ql-editor").html(paragraph1_data.content);

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
      url: "/api/updateAboutParagraph1",
      data: JSON.stringify({ "content": paragraph1.root.innerHTML }),
      processData: false,
      contentType: "application/json; charset=UTF-8",
    });

    setTimeout(() => endLoadingAnimation($(this)), 400);
  });

  //P2
  paragraph2 = new Quill("#paragraph-2-content", {
    theme: "snow",
    placeholder: "Type something here...",
  });
  $("#paragraph-2-content .ql-editor").html(paragraph2_data.content);

  paragraph2.on('text-change', function() {
    if (paragraph2.getLength() > LIMIT) {
      paragraph2.deleteText(LIMIT, paragraph2.getLength());
    }
  });

  $("#paragraph-2-form").submit(async function(e) {
    e.preventDefault();

    startLoadingAnimation($(this));

    await $.ajax({
      type: "PUT",
      url: "/api/updateAboutParagraph2",
      data: JSON.stringify({ "content": paragraph2.root.innerHTML }),
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
