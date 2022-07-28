import { tagRegExp, tagRegExpTitle } from './utils.js';

const appendTags = async () => {
  $("#tags-table tbody").empty();

  const tags = await $.getJSON("/api/fetchTags");

  tags.map((tag, index) => {
    $("#tags-table tbody").append(
      `<tr>
        <td style="width: 5rem">${index + 1}</td> 
        <td class="highlight-onhover" id="${tag._id}">
          <p>${tag.name}</p>
          <button type="button" class="btn remove-tag-btn">
            <ion-icon name="close-outline"></ion-icon>
          </button>
        </td>
      </tr>`
    );
  });
}

$(document).ready(async function() {
  $("#tag").attr("pattern", tagRegExp).attr("title", tagRegExpTitle); 
  await appendTags();

  $("#tags-table").on('click', ".remove-tag-btn", async function() {
    await $.ajax({
      type: "DELETE",
      url: "/api/deleteTag/" + $(this).siblings().text(),
    });
    
    appendTags();
  });

  $("#insert-tag").submit(async function(e) {
    e.preventDefault();
    
    await $.ajax({
      type: "POST",
      url: "/api/insertTag",
      contentType: "application/json; charset=UTF-8",
      processData: false,
      data: JSON.stringify({"name": $("#tag").val()}),
      success: function(data) {
        console.log(data);
      }
    });

    $("#tag").val("");
    appendTags();
  });
});
