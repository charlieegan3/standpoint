$(document).ready(function() {
  var w = 500,
      h = 500,
      r1 = h / 2,
      r0 = r1 - 80;

  var fill = d3.scale.category10();

  var chord = d3.layout.chord()
      .padding(.04)
      .sortSubgroups(d3.descending)
      .sortChords(d3.descending);

  var arc = d3.svg.arc()
      .innerRadius(r0)
      .outerRadius(r0 + 20);

  var svg = d3.select("#plot").append("svg:svg")
      .attr("width", w)
      .attr("height", h)
    .append("svg:g")
      .attr("transform", "translate(" + w / 2 + "," + h / 2 + ")");

  d3.json(window.location + "/chord_data.json", function(imports) {
    var indexByName = {},
        nodeByIndex = {},
        matrix = [],
        n = 0;

    // Compute a unique index for each word name.
    imports.forEach(function(d) {
      if (!(d.name in indexByName)) {
        nodeByIndex[n] = d;
        indexByName[d.name] = n++;
      }
    });

    // Construct a square matrix counting word connections.
    imports.forEach(function(d) {
      var source = indexByName[d.name];
      var row = matrix[source];
      if (!row) {
        row = matrix[source] = [];
        for (var i = -1; ++i < n;) row[i] = 0;
      }
      d.connections.forEach(function(d) { row[indexByName[d]]++; });
    });

    chord.matrix(matrix);

    var g = svg.selectAll("g.group")
        .data(chord.groups)
      .enter().append("svg:g")
        .attr("class", "group")
        .on("mouseover", fade(.02))
        .on("mouseout", fade(.80));

    g.append("svg:path")
        .style("stroke", function(d) { return fill(nodeByIndex[d.index].type); })
        .style("fill", function(d) { return fill(nodeByIndex[d.index].type); })
        .attr("d", arc);

    g.append("svg:text")
        .each(function(d) { d.angle = (d.startAngle + d.endAngle) / 2; })
        .attr("dy", ".35em")
        .attr("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
        .attr("transform", function(d) {
          return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
              + "translate(" + (r0 + 26) + ")"
              + (d.angle > Math.PI ? "rotate(180)" : "");
        })
        .text(function(d) { return nodeByIndex[d.index].lemma; });

    svg.selectAll("path.chord")
        .data(chord.chords)
      .enter().append("svg:path")
        .attr("class", "chord")
        .style("stroke", function(d) { return d3.rgb(fill(nodeByIndex[d.source.index].type)).darker(); })
        .style("fill", function(d) { return fill(nodeByIndex[d.source.index].type); })
        .attr("d", d3.svg.chord().radius(r0));

  });

  // Returns an event handler for fading a given chord group.
  function fade(opacity) {
    return function(d, i) {
      svg.selectAll("path.chord")
          .filter(function(d) { return d.source.index != i && d.target.index != i; })
        .transition()
          .style("stroke-opacity", opacity)
          .style("fill-opacity", opacity);
    };
  }
});
