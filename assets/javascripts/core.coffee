
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
    # --> Atualiza a posição das linhas conforme o elemento é arrastado <--
    #Pega a nova posição do elemento que foi arrastado
    bbox = @getBBox()
    newx = bbox.x + bbox.width/2
    newy = bbox.y + bbox.height/2
    #Ajusta a posição das linhas conectadas a este elemento
    if @.data("linefrom")?
      @.data("linefrom").forEach (e) =>
        #Pega a posição do elemento que não se moveu
        bbox = e.data("elto").getBBox()
        samex = bbox.x + bbox.width/2
        samey = bbox.y + bbox.height/2
        e.attr({path: "M #{newx} #{newy} L #{samex} #{samey}"})
    if @.data("lineto")?
      @.data("lineto").forEach (e) =>
        #Pega a posição do elemento que não se moveu
        bbox = e.data("elfrom").getBBox()
        samex = bbox.x + bbox.width/2
        samey = bbox.y + bbox.height/2
        e.attr({path: "M #{newx} #{newy} L #{samex} #{samey}"})

  width = 500
  height = 500

  paper = Raphael('canvas', 500, 500)

  set = paper.set()
  band = paper.path("M 0 0")
  x = 0
  y = 0
  oldid = 0

  rectSize = 50

  click = () ->
    oldx = x
    oldy = y
    dimensions = @getBBox()
    x = dimensions.x + dimensions.width/2
    y = dimensions.y + dimensions.height/2
    #Está no segundo click?
    if paper.canvas.onmousemove?
      #Caso o segundo click seja em um objeto diferente do clicado na primeira vez
      if @.id != oldid
        band.attr({path: "M #{oldx} #{oldy}L " + x + " " + y})
        #De onde a linha vem
        band.data('elfrom', paper.getById(oldid))
        #Para onde a linha vai
        band.data('elto', @)
        oldtemp = paper.getById(oldid)
        #Verifica se já existe um set
        #Se ele existir, adiciona a linha ao set existente
        if oldtemp.data('linefrom')?
          console.log("Adicionando linha id#{band.id} no set do obj de saida id#{oldid}")
          oldtemp.data('linefrom').push(band)
        #Se o set não existir, cria um set com a linha
        else
          console.log("Criando set com a linha id #{band.id} para o obj de saida id #{oldid}")
          newset = paper.set()
          newset.push(band)
          oldtemp.data('linefrom',newset)
        #Mesma coisa para o elemento de entrada da linha
        if @.data('lineto')?
          console.log("Adicionando linha id#{band.id} no set do obj de entrada id#{@.id}")
          @.data('lineto').push(band)
        else
          console.log("Criando set com a linha id #{band.id} para o obj de entrada id #{@.id}")
          newset = paper.set()
          newset.push(band)
          @.data('lineto',newset)
      #A linha será anulada caso o mesmo objeto seja clicado duas vezes 
      else
        band.remove()
    band = paper.path("M 0 0").attr({"stroke-width": 5})
    band.toBack() #Linha deve ficar atrás dos outros elementos
    band.node.style.pointerEvents = "none"
    if not paper.canvas.onmousemove?
      paper.canvas.onmousemove = (e) ->
        band.attr({path: "M " + x + " " + y + "L " + e.clientX + " " + e.clientY})
    else
      paper.canvas.onmousemove = null
    oldid = @.id

  set.push(paper.rect(100, 200, rectSize, rectSize)
    .attr
       fill: "#00f",
       stroke: "none",
       cursor: "move"
    .drag(move, start, end)
    .click(click)
  )

  set.push(paper.circle(50, 100, 20)
    .attr
      fill: '#f00',
      stroke: "none",
      data:
        fichas: 0
      cursor: "pointer"
    .drag(move, start, end)
    .click(click)
  )
  set.push(paper.circle(150, 100, 20)
    .attr
      fill: '#f00',
      stroke: "none",
      data:
        fichas: 0
      cursor: "pointer"
    .drag(move, start, end)
    .click(click)
  )

  $(window).resize () ->
    paper.setSize($(window).width(),$(window).height())