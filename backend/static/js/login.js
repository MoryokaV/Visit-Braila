$(document).ready(function() {
  $("form").submit(function(e) {
    e.preventDefault();

    $.ajax({
      url: "/login",
      type: "POST",
      data: JSON.stringify({ user: $("#user").val(), pass: $("#pass").val() }),
      processData: false,
      contentType: "application/json; charset=UTF-8",
      success: function(data) {
        window.location.replace(JSON.parse(data).url);
      },
      error: function(data) {
        alert(data.responseText);
      },
    });
  });

  $(".eye-icon").on("click", function() {
    const passwordField = $("#pass");

    if (passwordField.attr("type") === "password") {
      $(this).attr("name", "eye-outline");
      passwordField.attr("type", "text");
    } else {
      $(this).attr("name", "eye-off-outline");
      passwordField.attr("type", "password");
    }
  });
});
