function show_comment(id, extract_string) {
  $.get("/comments/" + id, function( data ) {
    $("#comment").html("");
    var text = $("<p class=\"comment-text\">");
    text.html(highlight_text(data.text, extract_string));
    $("#comment").append(text);
    if (data.parent_id) {
      var parent_link = $("<a href=\"#\">");
      parent_link.attr("data-parent", data.parent_id);
      parent_link.html("Show Parent");
      parent_link.click(function(event) {
        show_comment($(event.target).attr("data-parent"), $(event.target).html());
      });
      $("#comment").append(parent_link);
    }
  });
}

function highlight_text(comment, extract) {
  var new_comment = comment.replace(extract, "<mark>"+extract+"</mark>");
  if (new_comment === comment) {
    var trailing_cleaned_extract = extract.replace(/\W+$/, "")
    new_comment = comment.replace(trailing_cleaned_extract, "<mark>"+trailing_cleaned_extract+"</mark>");
  }
  if (new_comment === comment) {
    var tokens = extract.split(" ");
    for (var i = 0; i < tokens.length - 1; i++) {
      var bigram = tokens[i] + " " + tokens[i + 1];
      new_comment = new_comment.replace(bigram, "<mark>"+bigram+"</mark>");
    }
    new_comment = new_comment.replace(/<\/mark>(\W+)<mark>/g, "$1");
  }
  return new_comment;
}
