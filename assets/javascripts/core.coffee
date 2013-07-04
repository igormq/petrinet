
$ ->

  paper = Raphael($("#main"), "100%", "100%")

  circle = paper.circle(50, 40, 20)

  circle
    .attr
      fill: '#f00',
      stroke: "#fff",
      data:
        fichas: 0
      cursor: "pointer"
    .drag(
      (dx, dy) ->
          @attr
            cx: @ox + dx,
            cy: @oy + dy
      () ->
        @ox = @attr("cx")
        @oy = @attr("cy")
    )

  $(window).resize () ->
    paper.setSize($(window).width(),$(window).height())