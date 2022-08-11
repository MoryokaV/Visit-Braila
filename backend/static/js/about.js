import { startLoadingAnimation, endLoadingAnimation } from './utils.js';

let paragraph1 = undefined;
let paragraph2 = undefined;

const LIMIT = 500;

const updateParagraph = async (form, e, name, content) => {
  e.preventDefault();

  startLoadingAnimation(form);

  await $.ajax({
    type: "PUT",
    url: "/api/updateAboutParagraph",
    data: JSON.stringify({"name": name, "content": content}),
    processData: false,
    contentType: "application/json; charset=UTF-8",
  });
  
  setTimeout(() => endLoadingAnimation(form), 400);
}

$(document).ready(async function() {
  const contents = await $.getJSON("/api/fetchAboutParagraphs");

  // P1
  paragraph1 = new Quill("#paragraph-1-content", {
    theme: "snow", 
    placeholder: "Type something here...",
  });
  $("#paragraph-1-content .ql-editor").html(contents[0].content);

  paragraph1.on('text-change', function() {
    if(paragraph1.getLength() > LIMIT){
      paragraph1.deleteText(LIMIT, paragraph1.getLength());
    }
  });

  $("#paragraph-1-form").submit(function(e) {
    updateParagraph($(this), e, "paragraph1", paragraph1.root.innerHTML);
  });

  // P2
  paragraph2 = new Quill("#paragraph-2-content", {
    theme: "snow", 
    placeholder: "Type something here...",
  });
  $("#paragraph-2-content .ql-editor").html(contents[1].content);

  paragraph2.on('text-change', function() {
    if(paragraph2.getLength() > LIMIT){
      paragraph2.deleteText(LIMIT, paragraph2.getLength());
    }
  });

  $("#paragraph-2-form").submit(function(e) {
    updateParagraph($(this), e, "paragraph2", paragraph2.root.innerHTML);
  });
});
