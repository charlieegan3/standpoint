$(document).ready(function() {
  $.ajax({
    type: "POST",
    url: "/",
    data: JSON.stringify({sentence: "They went to the shop and bought milk"}),
    success: function(data, status) {
      renderResults(data);
    }
  });

  $("#submit").click(function() {
    $.ajax({
      type: "POST",
      url: "/",
      data: JSON.stringify({sentence: $('#query').val()}),
      success: function(data, status) {
        renderResults(data);
      }
    });
  });

  function renderResults(data) {
    var data = JSON.parse(data);

    $("#results").html('');
    for (i = 0; i < data.points.length; i++) {
      var tr = document.createElement("TR");
      $(tr).append('<td>' + data.points[i].string + '</td>');
      var frameString = "";
      var tagString = "";
      for (j = 0; j < data.points[i].frames.length; j++) {
        frameString += '<code>' + data.points[i].frames[j].pattern + "</code>, ";

        for (k = 0; k < data.points[i].frames[j].components.length; k++) {
          tags = data.points[i].frames[j].components[k].tags;
          if (tags.length > 0) {
            tagString += '<span class="label label-success">' +
                         data.points[i].frames[j].components[k].tags +
                         "</span>, ";
          }
        }
      }
      $(tr).append('<td>' + frameString.slice(0, -2)+ '</td>');
      $(tr).append('<td>' + tagString.slice(0, -2) + '</td>');
      $("#results").append(tr);
    }

    $("#raw").html('');
    $("#raw").append('<h4>Raw Response</h4>');
    $("#raw").append('<pre>'+JSON.stringify(data, null, '    ')+'</pre>');
  }

  function appendTextToResults(string) {
    $("#results")
      .append('<td>' + string + '</td>');
  }
});

