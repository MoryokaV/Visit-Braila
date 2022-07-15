import { fetchSights } from './scripts.js'

const closeModal = () => {
  $(".ql-toolbar").remove();
  $("#description").removeClass("ql-container ql-snow");

  $(".modal").removeClass("show");  
}

const appendSightImage = (image, index) => {
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
}

export const openUpdateModal = async (id) => {
  $(".close-btn").click(closeModal);

  let sight = await $.getJSON(window.origin + "/api/findSight/" + id);

  // NAME
  $("#name").val(sight.name);
  
  // TAGS
  $("#active-tags").empty()
  sight.tags.map((tag) => $("#active-tags").append(`<p class="tag-item">${tag}</p>`));
  //TODO: get tags for <option>

  // DESCRIPTION
  $("#description").html(sight.description)
  const quill = new Quill("#description", {
    theme: "snow",
  });

  // IMAGES
  $(".img-container").empty()
  sight.images.map((image, index) => appendSightImage(image, index));

  $('#images').change(function() {
    const new_images = $("#images").prop('files');
    Array.from(new_images).map((image, index) => {
      appendSightImage(image.name, index);
    });
  });

  $(".remove-img-btn").click(function (e) {
    e.preventDefault();

    sight.images.splice($(this).data("index"), 1)
    $(this).parent().remove();
  });
  
  // POSITION
  $("#position").val(sight.position) 

  // SUBMIT
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
        console.log(data);
      }
    });
    
    fetchSights();
    closeModal();
  });
}