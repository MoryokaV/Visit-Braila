export const getFilename = path => path.substring(path.lastIndexOf('/') + 1);
const diacritice = "ĂăÂâÎîȘșȚț";
const diacritice_mari = "ĂÂÎȘȚ";

// Loading animation
export const startLoadingAnimation = container => container.find(`button[type="submit"]`).addClass("loading-btn");
export const endLoadingAnimation = container => container.find(`button[type="submit"]`).removeClass("loading-btn");

// Form Validation
export const nameRegExp = `^[A-Za-z${diacritice}][A-Za-z0-9${diacritice},.\"'() -]*$`
export const addressRegExp = `^[A-Za-z0-9${diacritice}][A-Za-z0-9${diacritice},.\"'() -]*$`
export const tagRegExp = `^[A-Z${diacritice_mari}][A-Za-z${diacritice}]*$`
export const idRegExp = "^[0-9a-fA-F]{24}$"
export const phoneRegExp = "^(\\+4|)?(07[0-8]{1}[0-9]{1}|02[0-9]{2}|03[0-9]{2}){1}?([0-9]{3}){2}$"
export const latitudeRegExp = "^(\\+|-)?(?:90(?:(?:\\.0{1,15})?)|(?:[0-9]|[1-8][0-9])(?:(?:\\.[0-9]{1,15})?))$"
export const longitudeRegExp = "^(\\+|-)?(?:180(?:(?:\\.0{1,15})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\\.[0-9]{1,15})?))$"

export const nameRegExpTitle = "Name should start with a letter. Allowed characters: a-z A-Z 0-9 ,.\"'() -"
export const addressRegExpTitle = "Name shouldn't start with a symbol. Allowed characters: a-z A-Z 0-9 ,.\"'() -"
export const tagRegExpTitle = "Name should start with a capital letter. Allowed characters: a-z A-Z"
export const idRegExpTitle = "Please enter a valid id"
export const phoneRegExpTitle = "Please enter a valid RO phone number (no spaces allowed)"
export const latitudeRegExpTitle = "Invalid latitude coordinates"
export const longitudeRegExpTitle = "Invalid longitude coordinates"

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

  $("body").click(function(e) {
    if (!document.querySelector("aside").contains(e.target) && !document.querySelector(".menu-btn").contains(e.target)) {
      $('aside').removeClass("show");
    }
  });
});
