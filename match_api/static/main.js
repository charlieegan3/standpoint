$(document).ready(function() {
  $.ajax({
    type: "POST",
    url: "/",
    data: JSON.stringify({sentence: "I like cats, she likes dogs."}),
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
    $("#raw").html('');
    for (i = 0; i < data['matches'].length; i++) {
      $("#results").append('<tr>');
        appendTextToResults('Match: ' + i);
        appendTextToResults(data['matches'][i]['string']);
        appendTextToResults(data['matches'][i]['score']);
        appendTextToResults(data['matches'][i]['matched_frames']);
        appendTextToResults(data['matches'][i]['verb']['lemma']);
        appendTextToResults(data['matches'][i]['verb']['text']);
      $("#results").append('</tr>');
    }
    $("#raw").append('<h4>Raw Response</h4>');
    $("#raw").append('<pre>'+JSON.stringify(data, null, '  ')+'</pre>');
  }

  function appendTextToResults(string) {
    $("#results")
      .append('<td>' + string + '</td>');
  }
});

