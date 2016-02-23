$(document).ready(function() {
  $('.progress').hide();
  $.ajax({
    type: "POST",
    url: "/",
    data: JSON.stringify({sentence: "They went to the shop and bought milk"}),
    success: function(data, status) {
      renderResults(data);
    }
  });
  $("#input").html('They went to the shop and bought milk');

  $("#submit").click(function() {
    $('.progress').show();
    $.ajax({
      type: "POST",
      url: "/",
      data: JSON.stringify({sentence: $('#query').val()}),
      success: function(data, status) {
        renderResults(data);
        $("#input").html($('#query').val());
        $('.progress').hide();
      },
      error: function(data, status) {
        $('.progress').hide();
      }
    });
  });

  function renderResults(data) {
    var data = JSON.parse(data);

    $("#results").html('');
    if (data.length == 0) {
      $("#results").append("<p><code>There were no matches.</code></p>")
    }
    for (var i = 0; i < data.length; i++) {
      point = data[i]["nodes"];
      var table = document.createElement("table");
      $(table).addClass("table table-bordered table-condensed");
      var frame = document.createElement("tr");
      var match = document.createElement("tr");
      var lemma = document.createElement("tr");
      $(frame).append("<th>Frame</th>");
      $(match).append("<th>Named Match (by me)</th>");
      $(lemma).append("<th>Lemma</th>");
      for (var j = 0; j < point.length; j++) {
        $(frame).append("<td>"+point[j].component.string+"</td>");
        $(match).append("<td>"+point[j].match.tag+"</td>");
        $(lemma).append("<td>"+point[j].match.node.node.lemma+"</td>");
      }
      $(table).append(frame);
      $(table).append(match);
      $(table).append(lemma);
      $("#results").append("<p>Match " + (i+1).toString() + "</p>");
      $("#results").append("<p>" + data[i]["string"] + "</p>");
      $("#results").append(table);
    }

    $("#raw").html('');
    $("#raw").append('<pre>'+JSON.stringify(data, null, '    ')+'</pre>');
  }

  function appendTextToResults(string) {
    $("#results")
      .append('<td>' + string + '</td>');
  }
});

