function list_matching_patterns(pattern) {
  $.get( window.location + "/matching_patterns?pattern=" + pattern.name, function( data ) {
    var container = document.getElementById("list");
    container.innerHTML = "";
    for (var i = 0; i < data.length; i++) {
      var title = document.createElement("h2");
      title.innerHTML = data[i][0];
      $(container).append(title);
      var list = document.createElement("ul");
      for (var j = 0; j < data[i][1].length; j++) {
        var item = document.createElement("li");
        item.innerHTML = data[i][1][j].extract;
        $(list).append(item);
      }
      $(container).append(list);
    }
  });
}
