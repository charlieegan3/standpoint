function list_matching_patterns(pattern) {
  $.get(window.location.href.split("#")[0] + "/matching_patterns?pattern=" + pattern, function(data) {
    var container = document.getElementById("list");
    container.innerHTML = "";
    for (var i = 0; i < data.length; i++) {
      var title = $("<b>");
      title.append(build_clickable_pattern(data[i][0], pattern));
      $(container).append(title);
      var list = document.createElement("ul");
      for (var j = 0; j < data[i][1].length; j++) {
        var item = $("<li>");
        var link = $("<a href=\"#\">");
        link.html(data[i][1][j].extract);
        $(link).attr("data-comment", data[i][1][j].comment_id)
        $(link).click(function() {
          show_comment($(this).attr("data-comment"));
        });
        $(item).append(link);
        $(list).append(item);
      }
      $(container).append(list);
    }
  });
}

function build_clickable_pattern(pattern_string, current_pattern) {
  var span = $("<span>");
  var components = pattern_string.split(" ");
  for (var i = 0; i < components.length; i++) {
    var link = $("<a href=\"#\">");
    link.html(components[i]);
    if (components[i] === current_pattern) {
      link.attr("class", "current");
    }
    link.click(function(event) {
      list_matching_patterns($(event.target).html());
    });
    $(span).append(link);
    $(span).append(" ");
  }
  return span;
}
