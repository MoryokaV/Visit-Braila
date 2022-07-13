export function displayToast(data, type) {
    $.toast({
      heading: "<strong>Success</strong>",
      text: data,
      showHideTransition: "fade",
      position: "top-right",
      stack: false,
      icon: type,
      loaderBg: "rgba(40,167,69,.9)",
      bgColor: "rgba(40,167,69,.85)",
    });
}

export default displayToast;