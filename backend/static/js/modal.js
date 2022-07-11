export const openUpdateModal = async (id) => {
  const sight = await $.getJSON(window.origin + "/api/findSight/" + id)

  $("#name").val(sight.name);
  
  // sight.tags.map((tag) => $("#active-tags").append(`<p class="tag-item">${tag}</p>`))

  $("#description").html(sight.description)
  const quill = new Quill("#description", {
    theme: "snow",
  });

  // $("#images") 
  
  $("#position").val(sight.position) 
}