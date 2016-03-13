var fs = require('fs');
var textrank = require('textrank-node');
var summarizer = new textrank();

fs.readFile('../text.txt', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  console.log(summarizer.summarize(data, 5));
});

