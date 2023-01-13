export const getFilename = path => path.substring(path.lastIndexOf('/') + 1);
const diacritice = "ĂăÂâÎîȘșȚț";
const diacritice_mari = "ĂÂÎȘȚ";

// Loading animation
export const startLoadingAnimation = container => container.find(`button[type="submit"]`).addClass("loading-btn");
export const endLoadingAnimation = container => container.find(`button[type="submit"]`).removeClass("loading-btn");

// Form Validation
export const nameRegExp = `^[A-Za-z${diacritice}][A-Za-z0-9${diacritice},.\"'() -]*$`
export const addressRegExp = `^[A-Za-z0-9${diacritice}][A-Za-z0-9${diacritice},.\-\"'() &]*$`
export const tagRegExp = `^[A-Z${diacritice_mari}][A-Za-z${diacritice}]*$`
export const idRegExp = "^[0-9a-fA-F]{24}$"
export const phoneRegExp = "^(\\+4|)?(07[0-8]{1}[0-9]{1}|02[0-9]{2}|03[0-9]{2}){1}?([0-9]{3}){2}$"
export const latitudeRegExp = "^(\\+|-)?(?:90(?:(?:\\.0{1,15})?)|(?:[0-9]|[1-8][0-9])(?:(?:\\.[0-9]{1,15})?))$"
export const longitudeRegExp = "^(\\+|-)?(?:180(?:(?:\\.0{1,15})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\\.[0-9]{1,15})?))$"

export const nameRegExpTitle = "Name should start with a letter. Allowed characters: a-z A-Z 0-9 ,.\"'() -"
export const addressRegExpTitle = "Name shouldn't start with a symbol. Allowed characters: a-z A-Z 0-9 ,.\"'() -&/"
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

// Images
export const appendImageElement = (image, uploaded = false) => {
  $(".img-container").append(
    `<li class="highlight-onhover">
        <a ${uploaded ? `href="${image}" target="_blank"` : ``} class="group">
          ${uploaded ? `<ion-icon name="image-outline"></ion-icon>` : `<ion-icon name="cloud-upload-outline"></ion-icon>`}
          ${getFilename(image)}
        </a>
        <button type="button" class="btn btn-icon remove-img-btn">
          <ion-icon name="close-outline"></ion-icon>
        </button>
      </li>`
  );
}

const addPreviewImages = async (images) => {
  function getBase64(image) {
    const reader = new FileReader();

    return new Promise(resolve => {
      reader.onload = e => {
        resolve(e.target.result)
      };

      reader.readAsDataURL(image);
    });
  }

  const blobs = await Promise.all(images.map(image => getBase64(image)));

  blobs.map((blob) => $("#preview-images").append(`<img src="${blob}">`));

  if ($("#preview-primary-image").attr("src") === undefined) {
    $("#preview-primary-image").prop("src", $("#preview-images img").eq(0).prop("src"));
  }
}

export const addImages = (filelist, path, preview, current_images, formData, primary_elem) => {
  const images = Array.from(filelist).filter((image) => {
    if (current_images.includes(path + image.name)) {
      alert(`'${image.name}' is already present in list!`);
      return false;
    }

    return true;
  });

  if (preview === true) {
    addPreviewImages(images);
  }

  images.map((image) => {
    formData.append("files[]", image);
    current_images.push(path + image.name);

    appendImageElement(image.name);
  });

  primary_elem.attr("max", current_images.length);
}

const removePreviewImage = (elem, images) => {
  if (images.length === 1) {
    $("#preview-primary-image").removeAttr("src");
  }

  $("#preview-images img").eq(elem.parent().index()).remove();
}

export const removeImage = (elem, preview, current_images, formData, primary_elem, input_elem) => {
  if (parseInt(primary_elem.val()) === current_images.length) {
    primary_elem.val(current_images.length - 1);
  }

  if (current_images.length === 1) {
    input_elem.prop("required", true);
    primary_elem.val(1);
  }

  if (preview === true) {
    removePreviewImage(elem, current_images);
  }

  let files = [...formData.getAll("files[]")];
  formData.delete("files[]");
  files = files.filter((file) => file.name != getFilename(current_images[elem.parent().index()]));
  files.map((file) => formData.append("files[]", file));

  current_images.splice(elem.parent().index(), 1);

  primary_elem.change();
  primary_elem.attr("max", current_images.length);

  elem.parent().remove();
}

$(document).ready(function() {
  getStorageInfo();

  $(".menu-btn").click(() => $("aside").toggleClass("show"));

  $("body").click(function(e) {
    if (document.querySelector("aside") !== null) {
      if (!document.querySelector("aside").contains(e.target) && !document.querySelector(".menu-btn").contains(e.target)) {
        $('aside').removeClass("show");
      }
    }
  });
});
