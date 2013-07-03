$(function() {
  var circle, paper;
  paper = Raphael($("#main"), "100%", "100%");
  circle = paper.circle(50, 40, 10);
  circle.attr("fill", "#f00");
  circle.attr("stroke", "#fff");
  return $(window).resize(function() {
    return paper.setSize($(window).width(), $(window).height());
  });
});
