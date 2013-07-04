$(function() {
  var circle, paper;
  paper = Raphael($("#main"), "100%", "100%");
  circle = paper.circle(50, 40, 20);
  circle.attr({
    fill: '#f00',
    stroke: "#fff",
    data: {
      fichas: 0
    },
    cursor: "pointer"
  }).drag(function(dx, dy) {
    return this.attr({
      cx: this.ox + dx,
      cy: this.oy + dy
    });
  }, function() {
    this.ox = this.attr("cx");
    return this.oy = this.attr("cy");
  });
  return $(window).resize(function() {
    return paper.setSize($(window).width(), $(window).height());
  });
});
