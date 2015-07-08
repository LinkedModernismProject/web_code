d3sparql.sunburst = function(json, config) {
  var tree = d3sparql.tree(json, config);
  console.log('TREEEEE');
  console.log(tree);
  console.log(tree[0]);
  console.log(tree[1]);
  console.log(typeof(tree[0]));
  console.log(typeof(tree[1]));

  var opts = {
    "width":    config.width    || 1000,
    "height":   config.height   || 900,
    "margin":   config.margin   || 150,
    "selector": config.selector || "#visualizations"
  }

  var radius = Math.min(opts.width, opts.height) / 2 - opts.margin
  var x = d3.scale.linear().range([0, 2 * Math.PI])
  var y = d3.scale.sqrt().range([0, radius])
  var color = d3.scale.category20()
  var svg = d3.select(opts.selector).html("").append("svg")
    .attr("width", opts.width)
    .attr("height", opts.height)
    .append("g")
    .attr("transform", "translate(" + opts.width/2 + "," + opts.height/2 + ")");
  var arc = d3.svg.arc()
    .startAngle(function(d)  { return Math.max(0, Math.min(2 * Math.PI, x(d.x))) })
    .endAngle(function(d)    { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))) })
    .innerRadius(function(d) { return Math.max(0, y(d.y)) })
    .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)) })
  var partition = d3.layout.partition()
    .value(function(d) {return d.value})
  var nodes = partition.nodes(tree)
  console.log(nodes);
  console.log(nodes[0]);
  console.log(nodes[0].children[0].name);
  console.log(nodes[0].children[0].name._);
  var path = svg.selectAll("path")
    .data(nodes[0].children[0].name._)
    .enter()
    .append("path")
    .attr("d", arc)
    .attr("class", "arc")
    .style("fill", function(d) { return color((d.children ? d : d.parent).name) })  //console.log(d)})
    .on("click", click)
    console.log(path);
  var text = svg.selectAll("text")
    .data(nodes)
    .enter()
    .append("text")
    .attr("transform", function(d) {
      var rotate = x(d.x + d.dx/2) * 180 / Math.PI - 90
      return "rotate(" + rotate + ") translate(" + y(d.y) + ")"
    })
    .attr("dx", ".5em")
    .attr("dy", ".35em")
    .text(function(d) {return d.name})
    .on("click", click)

  // default CSS/SVG
  path.attr({
    "stroke": "#ffffff",
    "fill-rule": "evenodd",
  })
  text.attr({
    "font-size": "10px",
    "font-family": "sans-serif",
  })

  function click(d) {
    console.log('In click');
    path.transition()
      .duration(750)
      .attrTween("d", arcTween(d))
    text.style("visibility", function (e) {
        // required for showing labels just before the transition when zooming back to the upper level
        return isParentOf(d, e) ? null : d3.select(this).style("visibility")
      })
      .transition()
      .duration(750)
      .attrTween("transform", function(d) {
        return function() {
          var rotate = x(d.x + d.dx / 2) * 180 / Math.PI - 90
          return "rotate(" + rotate + ") translate(" + y(d.y) + ")"
        }
      })
      .each("end", function(e) {
        // required for hiding labels just after the transition when zooming down to the lower level
        d3.select(this).style("visibility", isParentOf(d, e) ? null : "hidden")
      })
  }
  function maxDepth(d) {
    console.log('In maxDepth');
    return d.children ? Math.max.apply(Math, d.children.map(maxDepth)) : d.y + d.dy
  }
  function arcTween(d) {
    console.log('In arcTween');
    var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
        yd = d3.interpolate(y.domain(), [d.y, maxDepth(d)]),
        yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius])
    return function(d) {
      return function(t) {
        x.domain(xd(t))
        y.domain(yd(t)).range(yr(t))
        return arc(d)
      }
    }
  }
  function isParentOf(p, c) {
    console.log(p);
    console.log(c);
    if (p === c) return true
    if (p.children) {
      return p.children.some(function(d) {
        return isParentOf(d, c)
      })
    }
    return false
  }
  console.log("Done Tree");
}//End of sunburst
