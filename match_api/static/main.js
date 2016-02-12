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
    if (data.points.length == 0) {
      $("#results").append("<p><code>There were no point matches, remember copula verbs are not handled.</code></p>")
    }

    for (var i = 0; i < data.points.length; i++) {
      var point = data.points[i];
      var well = document.createElement("div");
      well.className = "well";
      $(well).append("<h4>" + point.frame + "</h4>")
      $(well).append("<p class=\"small\">" + point.bare_frame + "<code>" + point.string + "</code>" + "</p>")
      var componentString = "<p>";
      for (var j = 0; j < point.matched_components.length; j++) {
        var component = point.matched_components[j];
        if (component.syntax != "/VB/") {
          componentString += "<span class=\"label label-primary\">" + component.semantics + "</span>";
        }
        componentString += "<code>" + component.syntax + "</code>";
        componentString += "<em>" + component.words+ "</em>";
        componentString += "</p>";
      }
      $(well).append("<p>" + componentString + "</p>")
      $("#results").append(well);
    }

    $("#frames").html('');
    for (var i = 0; i < data.unmatched_frames.length; i++) {
      var frame = data.unmatched_frames[i];
      var well = document.createElement("div");
      well.className = "well";
      $(well).append("<h4>" + frame.string+ "</h4>")
      if (frame.missing_representation) {
        $(well).append("<p><span class=\"label label-danger\">Missing Representation</span></p>")
      }
      $(well).append("<p>Verb: " + frame.verb + "</p>")
      $(well).append("<p>Parse was missing: </p>")
      $(well).append('<pre>'+JSON.stringify(frame.missing_relation, null, '    ')+'</pre>');
      $("#frames").append(well);
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

