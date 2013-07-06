
$ ->
  in_range = (val, start, size) ->
    !(val + size < start or val > start + size)

  line_collision = (x1, y1, width1, height1, x2, y2, width2, height2) ->
    a = {top: y1, bottom: y1+height1, left: x1, right: x1+width1}
    b = {top: y2, bottom: y2+height2, left: x2, right: x2+width2}

    !(a.left >= b.right or a.right <= b.left or
           a.top >= b.bottom or a.bottom <= b.top)
  start = () ->
    @ox = if @type == 'circle' then @attr("cx") else @attr("x")
    @oy = if @type == 'circle' then @attr("cy") else @attr("y")
    @attr
      cursor: "move",
      opacity: .5
  end = () ->
    @attr
      cursor: "pointer",
      opacity: 1.0
  move = (dx, dy) ->
    bbox = @getBBox()

    set.forEach (e) =>
      if e.id != @id
        bbox2 = e.getBBox()
        # keeps Circle in boarder
        x = @ox + dx

        y = @oy + dy

        if @type == 'circle'
          x = x - @attr('r')
          y = y - @attr('r')

        x = if x < 0 then 0 else (if x > width - bbox.width then width - bbox.width else x)


        y = if y < 0 then 0 else (if y > height - bbox.height then height - bbox.height else y)

        #collision system
        if not line_collision(bbox2.x, bbox2.y, bbox2.width, bbox2.height, x, bbox.y, bbox.width, bbox.height)
          if (@stuckx and ( not in_range(y, bbox2.y, bbox2.height) or Math.abs(x - bbox.x) < bbox.width)) or not @stuckx
            if @type == 'circle'
              @attr
                cx: x + @attr('r')
            else
              @attr
                x: x

            @pdx = dx
            @stuckx = false
        else
          @stuckx = true
          if @type == 'circle'
            @attr
              cx: if @pdx > dx then bbox2.x + bbox2.width + 1 + @attr('r') else bbox2.x - 1 - @attr('r')
          else
            @attr
              x: if @pdx > dx then bbox2.x + bbox2.width + 1 else bbox2.x - bbox.width - 1

        if not line_collision(bbox2.x, bbox2.y, bbox2.width, bbox2.height, bbox.x, y, bbox.width, bbox.height)
          if ((@stucky and ( not in_range(x, bbox2.x, bbox2.width) or Math.abs(y - bbox.y) < bbox.height) ) or not @stucky )
            if @type == 'circle'
              @attr
                cy: y + @attr('r')
            else
              @attr
                y: y
            @pdy = dy
            @stucky = false
        else
          @stucky = true
          if @type == 'circle'
            @attr
              cy: if @pdy > dy then bbox2.y + bbox2.height + 1 + @attr('r') else bbox2.y - 1 - @attr('r')
          else
            @attr
              y: if @pdy > dy then bbox2.y + bbox2.height + 1 else bbox2.y - bbox.height - 1

  width = 500
  height = 500

  paper = Raphael('canvas', 500, 500)

  set = paper.set()
  band = paper.path("M 0 0")
  x = 0
  y = 0

  rectSize = 50

  click = () ->
    oldx = x
    oldy = y
    dimensions = @getBBox()
    x = dimensions.x + dimensions.width/2
    y = dimensions.y + dimensions.height/2
    if paper.canvas.onmousemove?
      console.log("Entrei aqui oldx: " + oldx + "oldy: " + oldy)
      band.attr({path: "M #{oldx} #{oldy}L " + x + " " + y})
    band = paper.path("M 0 0").attr({"stroke-width": 5})
    band.node.style.pointerEvents = "none"
    if not paper.canvas.onmousemove?
      paper.canvas.onmousemove = (e) ->
        band.attr({path: "M " + x + " " + y + "L " + e.clientX + " " + e.clientY})
    else
      paper.canvas.onmousemove = null


  set.push(paper.rect(100, 200, rectSize, rectSize)
    .attr
       fill: "hsb(0, 0, 0)",
       stroke: "none",
       cursor: "move"
    .drag(move, start, end)
    .click(click)
  )

  set.push(paper.circle(50, 100, 20)
    .attr
      fill: '#f00',
      stroke: "#fff",
      data:
        fichas: 0
      cursor: "pointer"
    .drag(move, start, end)
    .click(click)
  )
  set.push(paper.circle(150, 100, 20)
    .attr
      fill: '#f00',
      stroke: "#fff",
      data:
        fichas: 0
      cursor: "pointer"
    .drag(move, start, end)
    .click(click)
  )

  $(window).resize () ->
    paper.setSize($(window).width(),$(window).height())