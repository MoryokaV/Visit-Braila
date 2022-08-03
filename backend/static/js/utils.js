export const getFilename = path => path.substring(path.lastIndexOf('/') + 1);

// Form Validation
export const nameRegExp = "^[A-Za-z][A-Za-z0-9,.\"'() ]*$"
export const addressRegExp = "^[A-Za-z0-9][A-Za-z0-9,.\"'() ]*$" 
export const tagRegExp = "^[A-Z][A-Za-z]*$"

export const nameRegExpTitle = "Name should start with a letter. Allowed characters: a-z A-Z 0-9 ,.\"'() "
export const addressRegExpTitle = "Name shouldn't start with a symbol. Allowed characters: a-z A-Z 0-9 ,.\"'() "
export const tagRegExpTitle = "Name should start with a capital letter. Allowed characters: a-z A-Z"

// Server storage info  
const getStorageInfo = async () => {
  const disk_usage = await $.getJSON("/api/serverStorage");

  $("#space-used").text(disk_usage.used + " GB");
  $("#space-total").text(disk_usage.total + " GB");
  
  $("#storage-bar").css("width", disk_usage.used * 100 / disk_usage.total + "%");
}

$(document).ready(function() {
  getStorageInfo();

  $(".menu-btn").click(() => $("aside").toggleClass("show"));
  
  $('body').click(function(e) {
    if(e.target.tagName !== "ASIDE" && !$(e.target).parent().hasClass("menu-btn")){
       $('aside').removeClass("show");
     }
  });
});
