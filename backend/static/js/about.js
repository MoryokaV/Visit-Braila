import { startLoadingAnimation, endLoadingAnimation, phoneRegExp, phoneRegExpTitle } from './utils.js';

let paragraph1 = undefined;
let paragraph2 = undefined;

const LIMIT = 500;

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
});
