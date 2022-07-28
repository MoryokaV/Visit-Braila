import { tags, tagRegExp, tagRegExpTitle } from './utils.js';

const appendTags = () => {
  $("#tags-table tbody").empty();
  tags.map((tag, index) => {
    $("#tags-table tbody").append(
      `<tr>
        <td style="width: 5rem">${index + 1}</td> 
        <td class="highlight-onhover">
          ${tag}
          <button type="button" class="btn remove-tag-btn">
            <ion-icon name="close-outline"></ion-icon>
          </button>
        </td>
      </tr>`
    );
  });
}

$(document).ready(function() {
  $("#tag").attr("pattern", tagRegExp).attr("title", tagRegExpTitle); 
   
  appendTags();
});
