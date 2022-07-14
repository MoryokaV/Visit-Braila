function displayToast(data, type) {
  $.toast({
    heading: "<strong>Success</strong>",
    text: data,
    showHideTransition: "fade",
    position: "top-right",
    stack: false,
    icon: type,
  });
}

export default displayToast;