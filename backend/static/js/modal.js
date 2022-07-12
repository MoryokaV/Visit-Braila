import { fetchSights } from './scripts.js'

const closeModal = () => {
  $(".ql-toolbar").remove();
  $("#description").removeClass("ql-container ql-snow");

  $(".modal").removeClass("show");  
}

export const openUpdateModal = async (id) => {
  $(".close-btn").click(function () {
    closeModal();   
  });

  let sight = await $.getJSON(window.origin + "/api/findSight/" + id);

  $("#name").val(sight.name);
  
  $("#active-tags").empty()
  sight.tags.map((tag) => $("#active-tags").append(`<p class="tag-item">${tag}</p>`));
  //TODO: get tags for <option>

  $("#description").html(sight.description)
  const quill = new Quill("#description", {
    theme: "snow",
  });

  $(".img-container").empty()
  sight.images.map((image, index) => {
    const filename = image.substring(image.lastIndexOf('/') + 1);

    $(".img-container").append(
        `<li class="img-preview">
          <a href="../static/media/${image}" class="group">
            <ion-icon name="image-outline"></ion-icon>
            ${filename}
          </a>
          <button class="btn remove-img-btn" data-index=index>
            <ion-icon name="close-outline"></ion-icon>
          </button>
        </li>`
      ); 
  });

  $(".remove-img-btn").click(function (e) {
    e.preventDefault();

    sight.images.splice($(this).data("index"), 1)
    $(this).parent().remove();
  });
  
  $("#position").val(sight.position) 

  $(".modal-body form").submit(function (e) {
    e.preventDefault();

    sight.name = $("#name").val();
    sight.description = quill.root.innerHTML;
    sight.position = $("#position").val();

    $.ajax({
      url: window.origin + "/api/updateSight/" + id,
      type: "PUT",
      data: JSON.stringify(sight),
      processData: false,
      contentType: "application/json; charset=UTF-8",
      success: function(data) {
        vt.success(data);
      }
    });
    
    fetchSights();
    closeModal();
  });
}