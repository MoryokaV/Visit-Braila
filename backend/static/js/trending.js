import './utils.js';

let items = [];

/*
const appendElements = async () => {
  items = await $.getJSON("/api/fetchTrendingItems");
  
  if(items.length === 0){
    $(".trending-list")
      .empty()
      .addClass("center")
      .append(`<p>No items in list</p>`);
    
    return;
  }

  $(".trending-list").removeClass("center").empty();

  const names = await Promise.all(items.map((item) => getSightName(item)));

  items.map((item, index) => {
    $(".trending-list").append(
      `<li draggable="true">
        <p>${item.index + 1}.</p>
        <p>${item.sight_id}</p>
        <div class="highlight-onhover" id="${item._id}">
          <p>${names[index]}</p>
          <button class="btn remove-item">
            <ion-icon name="close-outline"></ion-icon>
          </button>
        </div>
      </li>`
    );
  });
 
  const list = document.querySelector(".trending-list");
  new Sortable(list, {
    animation: 150,
    easing: "cubic-bezier(0.65, 0, 0.35, 1)",

    onMove: function(e) {
      $(e.dragged).find(" > p:first-child").text(`${$(e.related).index() + 1}.`);
      $(e.related).find(" > p:first-child").text(`${$(e.dragged).index() + 1}.`);
    },

    onEnd: async function(e) {
      await $.ajax({
        type: "PUT",
        url: "/api/updateTrendingItemIndex",
        data: JSON.stringify({_id: $(".trending-list li").eq(e.newIndex).find(" > div").attr('id'), newIndex: e.newIndex}),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });

      await $.ajax({
        type: "PUT",
        url: "/api/updateTrendingItemIndex",
        data: JSON.stringify({_id: $(".trending-list li").eq(e.oldIndex).find(" > div").attr('id'), newIndex: e.oldIndex}),
        processData: false,
        contentType: "application/json; charset=UTF-8",
      });
    }
  })
}
*/

const appendElements = () => {
  
}

const getSightName = async item => (await $.getJSON("/api/findSight/" + item.sight_id)).name;

$(document).ready(async function() {
  // Initialize
  appendElements(); 

  // Insert item 
  $("#add-item").click(function() {
    $(this).hide();
    $(".trending-form").show();   
  });

  // Remove item 
  $(".trending-list").on('click', ".remove-item", async function() {
    await $.ajax({
      type: "DELETE",
      url: "/api/deleteTrendingItem?" + $.param({_id: $(this).parent().attr('id'), index: $(this).parent().parent().index()}), 
    });
    
    appendElements();
  });
  
  // SUBMIT
  $(".trending-form").submit(async function(e) {
    e.preventDefault();
  
    const item = {
      sight_id: $("#sight-id").val(),
      index: items.length,
    }

    if(items.filter((i) => i.sight_id === item.sight_id).length > 0){
      alert("Item already present in list");
      $("#sight-id").val("");

      return;
    }

    const sight = await $.getJSON("/api/findSight/" + item.sight_id).catch((error) => alert(error.responseText));

    if(sight !== undefined) {
      await $.ajax({
        type: "POST",
        url: "/api/insertTrendingItem",
        contentType: "application/json; charset=UTF-8",
        processData: false,
        data: JSON.stringify(item),
        success: function(data) {
          console.log(data);
        }
      });

      appendElements();
    }

    $("#add-item").show();
    $("#sight-id").val("");
    $(this).hide();
  });

  $("body").click(function(e) {
    if(!document.querySelector(".trending-form").contains(e.target) && !document.querySelector("#add-item").contains(e.target)){
      $(".trending-form").hide();
      $("#add-item").show();
    }
  });
});
