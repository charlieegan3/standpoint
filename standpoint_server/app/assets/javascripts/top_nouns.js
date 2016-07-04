$(document).ready(function() {
  $.get(window.location.href.split("#")[0] + "/top_nouns", function(data) {
    var limit = data.length;
    if (limit >= 10) { limit = 10; }
    for (var i = 0; i < limit; i++) {
      var link = $("<a href=\"#\">");
      link.html(data[i][0]);
      link.click(function(event) {
        list_matching_patterns($(event.target).html());
      });
      var count = $("<span class=\"count\">");
      count.html("&nbsp;(" + data[i][1] + ")");
      $("#top_nouns").append(link, count, ", ");
    }
  });
});
