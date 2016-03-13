var fs = require('fs');
var sum = require('summarizely');

fs.readFile('../text.txt', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  console.log(sum(data));
});

