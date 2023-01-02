import { tagRegExp, tagRegExpTitle } from './utils.js';

let tags = [];

const fetchTags = async () => {
  $("#tags-table tbody").empty();

  tags = await $.getJSON("/api/fetchTags");

  tags.map((tag, index) => {
    $("#tags-table tbody").append(
      `<tr>
        <td class="small-cell">${index + 1}</td> 
        <td>
          <div class="highlight-onhover" id="${tag._id}">
            <p>${tag.name}</p>
            <button type="button" class="btn btn-icon remove-tag-btn">
              <ion-icon name="close-outline"></ion-icon>
            </button>
          </div>
        </td>
      </tr>`
    );
  });
}

$(document).ready(async function() {
  $("#tag").attr("pattern", tagRegExp).attr("title", tagRegExpTitle);
  await fetchTags();

  $("#tags-table").on('click', ".remove-tag-btn", async function() {
    await $.ajax({
      type: "DELETE",
      url: "/api/deleteTag/" + $(this).siblings().text(),
    });

    await fetchTags();
  });

  $("#insert-tag-form").submit(async function(e) {
    e.preventDefault();

    if (tags.filter((tag) => tag.name === $("#tag").val()).length > 0) {
      alert("Tag already exists");
      return;
    }

    await $.ajax({
      type: "POST",
      url: "/api/insertTag",
      contentType: "application/json; charset=UTF-8",
      processData: false,
      data: JSON.stringify({ "name": $("#tag").val() }),
    });

    $("#tag").val("");

    await fetchTags();
  });
});
