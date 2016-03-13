var fs = require('fs');
var lexrank = require('lexrank');

fs.readFile('../text.txt', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  var topLines = lexrank.summarize(data, 5, function (err, toplines, text) {
    if (err) {
      return console.log(err);
    }
    console.log(toplines);
  });
});

