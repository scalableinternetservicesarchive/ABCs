(function() {
  d3.legend = function(g) {
  g.each(function() {
    var g= d3.select(this),
        items = {},
        svg = d3.select(g.property("nearestViewportElement")),
        legendPadding = g.attr("data-style-padding") || 5,
        lb = g.selectAll(".legend-box").data([true]),
        li = g.selectAll(".legend-items").data([true]);

    lb.enter().append("rect").classed("legend-box",true);
    li.enter().append("g").classed("legend-items",true);

    svg.selectAll("[data-legend]").each(function() {
        var self = d3.select(this);
        items[self.attr("data-legend")] = {
          pos : self.attr("data-legend-pos") || this.getBBox().y,
          color : self.attr("data-legend-color") != undefined ? self.attr("data-legend-color") : self.style("fill") != 'none' ? self.style("fill") : self.style("stroke")
        };
      });

    items = d3.entries(items).sort(function(a,b) { return a.value.pos-b.value.pos; });

    li.selectAll("text")
        .data(items,function(d) { return d.key; })
        .call(function(d) { d.enter().append("text"); })
        .call(function(d) { d.exit().remove(); })
        .attr("y",function(d,i) { return i+"em"; })
        .attr("x","1em")
        .text(function(d) { return d.key; });

    li.selectAll("circle")
        .data(items,function(d) { return d.key; })
        .call(function(d) { d.enter().append("circle"); })
        .call(function(d) { d.exit().remove(); })
        .attr("cy",function(d,i) { return i-0.25+"em"; })
        .attr("cx",0)
        .attr("r","0.4em")
        .style("fill",function(d) { return d.value.color; });

    // Reposition and resize the box
    var lbbox = li[0][0].getBBox();
    lb.attr("x",(lbbox.x-legendPadding))
        .attr("y",(lbbox.y-legendPadding))
        .attr("height",(lbbox.height+2*legendPadding))
        .attr("width",(lbbox.width+2*legendPadding));
  });
  return g;
};
})();

function resize() {
    // update width
    width = parseInt(d3.select('#graph').style('width'), 10);
    width = width = $("#graph").width() - margin.left - margin.right;

    // resize the chart
    x.range([0, width]);
    d3.select(chart.node().parentNode)
        .style('height', (y.rangeExtent()[1] + margin.top + margin.bottom) + 'px')
        .style('width', (width + margin.left + margin.right) + 'px');

    chart.selectAll('rect.background')
        .attr('width', width);

    chart.selectAll('rect.percent')
        .attr('width', function(d) { return x(d.percent); });

    // update median ticks
    var median = d3.median(chart.selectAll('.bar').data(),
        function(d) { return d.percent; });

    chart.selectAll('line.median')
        .attr('x1', x(median))
        .attr('x2', x(median));

    // update axes
    chart.select('.x.axis.top').call(xAxis.orient('top'));
    chart.select('.x.axis.bottom').call(xAxis.orient('bottom'));
}

d3.select(window).on('resize', resize);

d3.select("div#graph")
   .append("div")
   .classed("svg-container", true) //container class to make it responsive
   .append("svg")
   //responsive SVG needs these 2 attributes and no width and height attr
   .attr("preserveAspectRatio", "xMinYMin meet")
   .attr("viewBox", "0 0 600 400")
   //class to make it responsive
   .classed("svg-content-responsive", true);


function loadGroupedBarChart(data) {
    var margin = {top: 20, right: 40, bottom: 100, left: 50},
    height = 500 - margin.top - margin.bottom;
    var width = $("#graph").width() - margin.left - margin.right;

    var parseDate = d3.time.format("%Y-%m-%d").parse;

    var x = d3.time.scale()
        .range([0, width]);

    var y = d3.scale.linear()
        .range([height, 0]);

    var color = d3.scale.category10();

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    var line = d3.svg.line()
        .interpolate("basis")
        .x(function(d) { return x(d.date); })
        .y(function(d) { return y(d.temperature); });

    var svg = d3.select("#graph").append("svg")
        .style("width", width + margin.left + margin.right)
        .style("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    color.domain(d3.keys(data[0]).filter(function(key) { return key !== "date"; }));

    data.forEach(function(d) {
      d.date = parseDate(d.date);
    });

    var data_points = color.domain().map(function(name) {
      return {
        name: name,
        values: data.map(function(d) {
          return {date: d.date, temperature: +d[name]};
        })
      };
    });

    x.domain(d3.extent(data, function(d) { return d.date; }));

    y.domain([
      d3.min(data_points, function(c) { return d3.min(c.values, function(v) { return v.temperature; }); }),
      d3.max(data_points, function(c) { return d3.max(c.values, function(v) { return v.temperature; }); })
    ]);

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
      .selectAll("text")
        .attr("y", 0)
        .attr("x", 9)
        .attr("dy", ".35em")
        .attr("transform", "rotate(70)")
        .style("text-anchor", "start");

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Value ($)");

    var city = svg.selectAll(".city")
        .data(data_points)
      .enter().append("g")
        .attr("class", "city");

    city.append("path")
        .attr("class", "line")
        .attr("d", function(d) { return line(d.values); })
        .attr("data-legend",function(d) { return d.name; })
        .style("stroke", function(d) { return color(d.name); });

    // city.append("text")
    //     .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
    //     .attr("transform", function(d) { return "translate(" + x(d.value.date) + "," + y(d.value.temperature) + ")"; })
    //     .attr("x", 3)
    //     .attr("dy", ".35em")
    //     .text(function(d) { return d.name; });

    legend = svg.append("g")
        .attr("class","legend")
        .attr("transform","translate(50,30)")
        .style("font-size","12px")
        .call(d3.legend);
}