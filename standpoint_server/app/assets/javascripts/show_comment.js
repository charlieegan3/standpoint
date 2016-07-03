function show_comment(id) {
  $.get("/comments/" + id, function( data ) {
    $("#comment").html("");
    var text = $("<p>");
    text.html(data.text);
    $("#comment").append(text);
    if (data.parent_id) {
      var parent_link = $("<a href=\"#\">");
      parent_link.attr("data-parent", data.parent_id);
      parent_link.html("Show Parent");
      parent_link.click(function(event) {
        show_comment($(event.target).attr("data-parent"));
      });
      $("#comment").append(parent_link);
    }
  });
}
