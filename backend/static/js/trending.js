import { idRegExp, idRegExpTitle } from './utils.js';

let items = [];

const appendElements = async () => {
  items = await $.getJSON("/api/fetchTrendingItems");

  if (items.length === 0) {
    $(".trending-container")
      .empty()
      .addClass("empty")
      .append(`<p>No items in list</p>`);

    return;
  }

  $(".trending-container").removeClass("empty").empty();

  const sights = await Promise.all(items.map((item) => getSight(item)));

  items.map((item, index) => {
    $(".trending-container").append(
      `<article class="trending-item" id="${item._id}">
        <img src="${sights[index].images[sights[index].primary_image - 1]}" alt="${sights[index].name}">
        <footer>
          <p>${sights[index].name}</p>
          <div class="loading-spinner"></div>
          <ion-icon name="heart-outline"></ion-icon>
          <button class="btn btn-icon remove-item">
            <ion-icon name="close-outline"></ion-icon>
          </button>
        </footer>
      </article>`
    );
  });

  const list = document.querySelector(".trending-container");

  new Sortable(list, {
    animation: 150,
    easing: "cubic-bezier(0.65, 0, 0.35, 1)",
    delay: 75,
    delayOnTouchOnly: true,
    onEnd: async function(e) {
      for (let i = Math.min(e.oldIndex, e.newIndex); i <= Math.max(e.oldIndex, e.newIndex); i++) {
        $(".trending-container article").eq(i).find("footer").addClass("loading");
      }

      for (let i = Math.min(e.oldIndex, e.newIndex); i <= Math.max(e.oldIndex, e.newIndex); i++) {
        await $.ajax({
          type: "PUT",
          url: "/api/updateTrendingItemIndex",
          data: JSON.stringify({ _id: $(".trending-container article").eq(i).attr('id'), newIndex: i }),
          processData: false,
          contentType: "application/json; charset=UTF-8",
        });

        await new Promise(resolve => {
          setTimeout(() => {
            $(".trending-container article").eq(i).find("footer").removeClass("loading");
            resolve();
          }, 250);
        });
      }
    }
  });
}

const getSight = async item => await $.getJSON("/api/findSight/" + item.sight_id);

$(document).ready(async function() {
  // Initialize
  appendElements();

  // Insert item 
  $("#sight-id").attr("pattern", idRegExp).attr("title", idRegExpTitle);

  $("#add-item").click(function() {
    $(this).addClass("d-none");
    $("#trending-form").removeClass("d-none");
  });

  // Remove item 
  $(".trending-container").on('click', ".remove-item", async function() {
    const article = $(this).parent().parent();

    await $.ajax({
      type: "DELETE",
      url: "/api/deleteTrendingItem?" + $.param({ _id: article.attr('id'), index: article.index() }),
    });

    appendElements();
  });

  // SUBMIT
  $("#trending-form").submit(async function(e) {
    e.preventDefault();

    const item = {
      sight_id: $("#sight-id").val(),
      index: items.length,
    }

    if (items.filter((i) => i.sight_id === item.sight_id).length > 0) {
      alert("Item already present in list");
      $("#sight-id").val("");

      return;
    }

    const sight = await $.getJSON("/api/findSight/" + item.sight_id).catch((error) => alert(error.responseText));

    if (sight !== undefined) {
      await $.ajax({
        type: "POST",
        url: "/api/insertTrendingItem",
        contentType: "application/json; charset=UTF-8",
        processData: false,
        data: JSON.stringify(item),
      });

      appendElements();
    }

    $("#add-item").removeClass("d-none");
    $("#sight-id").val("");
    $(this).addClass("d-none");
  });

  $("body").click(function(e) {
    if (!document.querySelector("#trending-form").contains(e.target) && !document.querySelector("#add-item").contains(e.target)) {
      $("#add-item").removeClass("d-none");
      $("#trending-form").addClass("d-none");
    }
  });
});
