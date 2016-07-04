$(document).ready(function() {
  var timerid;
  $("#query").on("input",function(e){
	var value = $(this).val();
	if ($(this).data("lastval") != value) {
	  $(this).data("lastval",value);
	  clearTimeout(timerid);
	  timerid = setTimeout(function() {
        list_matching_patterns(value, "word");
	  }, 300);
	};
  });
});
