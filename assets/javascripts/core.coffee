
$ ->

  paper = Raphael($("#main"), "100%", "100%")

  circle = paper.circle(50, 40, 10)

  circle.attr("fill", "#f00")


  circle.attr("stroke", "#fff")

  $(window).resize () ->
    paper.setSize($(window).width(),$(window).height())