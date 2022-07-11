export const openUpdateModal = async (id) => {
  let sight = await $.getJSON(window.origin + "/api/findSight/" + id)

  $("#name").val(sight.name);
  
  sight.tags.map((tag) => $("#active-tags").append(`<p class="tag-item">${tag}</p>`));
  //TODO: get tags for <option>

  $("#description").html(sight.description)
  const quill = new Quill("#description", {
    theme: "snow",
  });

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
}