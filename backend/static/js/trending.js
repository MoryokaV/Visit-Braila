import './utils.js';

let items = [];

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
      `<li>
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
