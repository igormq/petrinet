
@in_range = (val, start, size) ->
  !(val + size < start or val > start + size)

@line_collision = (x1, y1, width1, height1, x2, y2, width2, height2) ->
  a = {top: y1, bottom: y1+height1, left: x1, right: x1+width1}
  b = {top: y2, bottom: y2+height2, left: x2, right: x2+width2}
  not (a.left >= b.right or a.right <= b.left or a.top >= b.bottom or a.bottom <= b.top)

@start = () ->
    @ox = @attr("x")
    @oy = @attr("y")
    @attr
      cursor: "move",
      opacity: .5
@end = () ->
  @attr
    cursor: "pointer",
    opacity: 1.0

@move = (dx, dy) ->
  bbox = @getBBox()

  x = @ox + dx

  y = @oy + dy

  x = if x < 0 then 0 else (if x > CANVAS_LARGURA - bbox.width then width - bbox.width else x)


  y = if y < 0 then 0 else (if y > CANVAS_ALTURA - bbox.height then height - bbox.height else y)

  if objetos.length <= 1
    @attr
      x: x,
      y: y
    return true

  intersection = null


  objetos.forEach (e) =>
    if e.id != @id
      bbox2 = e.getBBox()

      #collision system
      if not line_collision(bbox2.x, bbox2.y, bbox2.width, bbox2.height, x, bbox.y, bbox.width, bbox.height)
        if (@stuckx and ( not in_range(y, bbox2.y, bbox2.height) or Math.abs(x - bbox.x) < bbox.width)) or not @stuckx
            @nx = x
            @stuckx = false
      else
        @stuckx = true
        @nx = if @pdx > dx then bbox2.x + bbox2.width + 1 else bbox2.x - bbox.width - 1
        return false
    return true
  if not @stuckx
    @pdx = dx
  @attr
    x: @nx

  objetos.forEach (e) =>
    if e.id != @id
      bbox2 = e.getBBox()
      if not line_collision(bbox2.x, bbox2.y, bbox2.width, bbox2.height, bbox.x, y, bbox.width, bbox.height)
        if ((@stucky and ( not in_range(x, bbox2.x, bbox2.width) or Math.abs(y - bbox.y) < bbox.height) ) or not @stucky )
          @ny = y
          @stucky = false
      else
        @stucky = true
        @ny = if @pdy > dy then bbox2.y + bbox2.height + 1 else bbox2.y - bbox.height - 1
        return false
    return true
  if not @stucky
    @pdy = dy
  @attr
    y: @ny
  # --> Atualiza a posição das linhas conforme o elemento é arrastado <--
  #Pega a nova posição do elemento que foi arrastado
  bbox = @getBBox()
  newx = bbox.x + bbox.width / 2
  newy = bbox.y + bbox.height / 2
  #Ajusta a posição das linhas conectadas a este elemento
  if @data("linefrom")?
    @data("linefrom").forEach (e) =>
      #Pega a posição do elemento que não se moveu
      bbox2 = e.data("elto").getBBox()
      samex = bbox2.x + bbox2.width/2
      samey = bbox2.y + bbox2.height/2
      ang = 360 - Raphael.angle(samex,samey,newx,newy) #Acerta o ângulo para começar em 0 a partir do eixo X
      ang = ang * Math.PI / 180 #Conversão para radianos
      finalX = samex - bbox2.width*Math.cos(ang)/2
      finalY = samey + bbox2.height*Math.sin(ang)/2
      e.attr({path: "M #{newx} #{newy} L #{finalX} #{finalY}"})
  if @data("lineto")?
    @data("lineto").forEach (e) =>
      #Pega a posição do elemento que não se moveu
      bbox2 = e.data("elfrom").getBBox()
      samex = bbox2.x + bbox2.width/2
      samey = bbox2.y + bbox2.height/2
      ang = 360 - Raphael.angle(newx,newy,samex,samey) #Acerta o ângulo para começar em 0 a partir do eixo X
      ang = ang * Math.PI / 180 #Conversão para radianos
      finalX = newx - bbox.width*Math.cos(ang)/2
      finalY = newy + bbox.height*Math.sin(ang)/2
      e.attr({path: "M #{samex} #{samey} L #{finalX} #{finalY}"})
