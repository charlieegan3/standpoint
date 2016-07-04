$(document).ready(function() {
  d3.json(window.location.href.split("#")[0] + "/graph_data.json", function(graph) {
    var width = 400,
        height = 400;

    var color = d3.scale.category10();

    var force = d3.layout.force()
        .charge(-120)
        .linkDistance(200)
        .size([width, height]);

    var svg = d3.select("#graph")
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    force.nodes(graph.nodes)
        .links(graph.links)
        .start();

    var link = svg.selectAll(".link")
        .data(graph.links)
        .enter().append("line")
        .attr("class", "link")
        .style("stroke-width", "1px")
        .style("stroke", "#d9d9d9");

    var node = svg.selectAll(".node")
        .data(graph.nodes)
        .enter().append("g")
        .attr("class", "node")
        .call(force.drag)
        .on("mousedown", function(d) {
          d.fixed = true;
          d3.select(this).classed("sticky", true);
        })
        .on("mouseover", function(d) {
          list_matching_patterns(d.name, "pattern");
        });

    node.append("circle")
        .attr("r", function (d) {
          return Math.log(d.value) * 5;
        })
        .style("fill", function (d) {
          return color(d.group);
        });

    node.append("text")
          .attr("text-anchor", "middle")
          .attr("dy", 4)
          .text(function(d) { return d.lemma});

    force.on("tick", function () {
        link.attr("x1", function (d) { return d.source.x; })
            .attr("y1", function (d) { return d.source.y; })
            .attr("x2", function (d) { return d.target.x; })
            .attr("y2", function (d) { return d.target.y; });

        d3.selectAll("circle")
            .attr("cx", function (d) { return d.x; })
            .attr("cy", function (d) { return d.y; });

        d3.selectAll("text")
            .attr("x", function (d) { return d.x; })
            .attr("y", function (d) { return d.y; });
    });
  });
});
