$(document).ready(function() {
  $.ajax({
    type: "POST",
    url: "/",
    data: JSON.stringify({sentence: "They went to paris and berlin"}),
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
    for (i = 0; i < data['points'].length; i++) {
      $("#results").append('<li>' + data['points'][i] + '</li>');
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

