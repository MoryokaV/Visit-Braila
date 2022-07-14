$(document).ready(function () {
  $("form button").click(function() {
    event.preventDefault()
    $.ajax({
      url: window.origin + "/login",
      type: "POST",
      data: JSON.stringify({"user": $("#user").val(), "pass": $("#pass").val()}),
      processData: false,
      contentType: "application/json; charset=UTF-8",
      success: function(data) {
        window.location.replace("/admin")
      },
      error: function(data) {
        alert(data.responseText)
      }
    });
  });  
});