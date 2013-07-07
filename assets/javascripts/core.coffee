
$ ->
  in_range = (val, start, size) ->
    !(val + size < start or val > start + size)

  line_collision = (x1, y1, width1, height1, x2, y2, width2, height2) ->
    a = {top: y1, bottom: y1+height1, left: x1, right: x1+width1}
    b = {top: y2, bottom: y2+height2, left: x2, right: x2+width2}
    not (a.left >= b.right or a.right <= b.left or a.top >= b.bottom or a.bottom <= b.top)

  start = () ->
    @ox = @attr("x")
    @oy = @attr("y")
    @attr
      cursor: "move",
      opacity: .5
  end = () ->
    @attr
      cursor: "pointer",
      opacity: 1.0

  move = (dx, dy) ->
    bbox = @getBBox()

    x = @ox + dx

    y = @oy + dy

    x = if x < 0 then 0 else (if x > width - bbox.width then width - bbox.width else x)


    y = if y < 0 then 0 else (if y > height - bbox.height then height - bbox.height else y)

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

  width = 500
  height = 500

  paper = Raphael('canvas', 500, 500)
  paper.ca.x = (num) ->
    if @type == 'circle'
      return { cx: num + @attr('r') }
    { x: num }
  paper.ca.y = (num) ->
    if @type == 'circle'
      return { cy: num + @attr('r') }
    { y: num }

  objetos = paper.set()
  band = paper.path("M 0 0")
  x = 0
  y = 0
  oldid = 0

  rectSize = 50

  dblclick = () ->
    $('.editar-atributos').show()
    $(".editar-atributos input[type='text'].fichas").val(@data('fichas'))
    $('.editar-atributos').css 'top', "#{@attr('cy')}px"
    $('.editar-atributos').css 'left', "#{@attr('cx')}px"
    $('.editar-atributos').data 'element-id', "#{@id}"
  click = () ->
    $('.menu').hide()
    $('.editar-atributos').hide()
    if @ox != @attr("x") and @oy != @attr("y")
      return false
    oldx = x
    oldy = y
    dimensions = @getBBox()
    x = dimensions.x + dimensions.width/2
    y = dimensions.y + dimensions.height/2
    #Está no segundo click?
    if paper.canvas.onmousemove?
      #Caso o segundo click seja em um objeto diferente do clicado na primeira vez
      if (@id != oldid) && (@type != paper.getById(oldid).type)
        connected = false
        if @data('lineto')?
          @data('lineto').forEach (e) =>
            if e.data("elfrom").id == oldid
              connected = true
        console.log("connected is #{connected}")
        if !connected
          console.log(@type)
          console.log(paper.getById(oldid).type)
          console.log(@type != paper.getById(oldid).type)
          ang = 360 - Raphael.angle(x,y,oldx,oldy) #Acerta o ângulo para começar em 0 a partir do eixo X
          ang = ang * Math.PI / 180 #Conversão para radianos
          finalX = x - dimensions.width*Math.cos(ang)/2
          finalY = y + dimensions.height*Math.sin(ang)/2
          band.attr({path: "M #{oldx} #{oldy}L #{finalX} #{finalY}"})
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
          if @data('lineto')?
            console.log("Adicionando linha id#{band.id} no set do obj de entrada id#{@id}")
            @data('lineto').push(band)
          else
            console.log("Criando set com a linha id #{band.id} para o obj de entrada id #{@id}")
            newset = paper.set()
            newset.push(band)
            @data('lineto',newset)
        else
          band.remove() #A linha será excluída caso já exista outra que faça a mesma conexão
      #A linha será anulada caso o mesmo objeto seja clicado duas vezes
      else
        band.remove()
    band = paper.path("M 0 0").attr({"stroke-width": 5, "arrow-end": "block-narrow-short"})
    band.toBack() #Linha deve ficar atrás dos outros elementos
    band.node.style.pointerEvents = "none"
    if not paper.canvas.onmousemove?
      paper.canvas.onmousemove = (e) ->
        band.attr({path: "M #{x} #{y}L #{e.clientX} #{e.clientY}"})
      @undrag()
    else
      paper.canvas.onmousemove = null
      paper.getById(oldid).drag(move, start, end)
    oldid = @id


  # objetos.push(paper.circle(50, 100, 20)
  #   .attr
  #     x: 30,
  #     y: 80,
  #     fill: '#f00',
  #     stroke: "none",
  #     data:
  #       fichas: 0
  #     cursor: "pointer"
  #   .drag(move, start, end)
  #   .click(click)
  #   .dblclick(dblclick)
  # )
  # objetos.push(paper.circle(150, 100, 20)
  #   .attr
  #     x: 130,
  #     y: 80,
  #     fill: '#0f0',
  #     stroke: "none",
  #     data:
  #       fichas: '0'
  #     cursor: "pointer"
  #   .drag(move, start, end)
  #   .click(click)
  #   .dblclick(dblclick)
  # )

  objetos.push(paper.rect(100, 200, rectSize, rectSize)
    .attr
       fill: "#00f",
       stroke: "none",
       cursor: "move"
    .drag(move, start, end)
    .click(click)
  )
  # objetos.push(paper.rect(200, 200, rectSize, rectSize)
  #   .attr
  #      fill: "#00f",
  #      stroke: "none",
  #      cursor: "move"
  #   .drag(move, start, end)
  #   .click(click)
  # )


  $(window).resize () ->
    paper.setSize($(window).width(),$(window).height())

  paper.canvas.onclick = (e) ->
    if $('.editar-atributos').is ':visible'
      $('.editar-atributos').hide()
    else if not paper.canvas.onmousemove?
      if $('.editar-atributos').is ':visible'
        $('.editar-atributos').hide()
      else
        element = paper.getElementByPoint(e.clientX, e.clientY)
        if  element == null
          if $('.menu').is ':visible'
            $('.menu').hide()
          else
            $('.menu').show()
            $('.menu').css 'top', "#{e.clientY}px"
            $('.menu').css 'left', "#{e.clientX}px"
            $('.menu').data 'x', "#{e.clientX}"
            $('.menu').data 'y', "#{e.clientY}"


  #previnir o click com o botao direito
  $(paper.canvas).bind "contextmenu", (e) ->
    $('.menu').hide()
    $('.editar-atributos').hide()
    e.preventDefault()


  $('.menu .btn').click () ->
    if $(@).hasClass('lugar')
      objetos.push(paper.circle(+$(@).parent().data('x'), +$(@).parent().data('y'), 20)
      .attr
        x: +$(@).parent().data('x') - 20,
        y: +$(@).parent().data('y') - 20,
        fill: '#12394d',
        stroke: "none",
        data:
          fichas: '0'
        cursor: "pointer"
      .drag(move, start, end)
      .click(click)
      .dblclick(dblclick)
      )
    else if $(@).hasClass('transicao')
      objetos.push(paper.rect(+$(@).parent().data('x'), +$(@).parent().data('y'), rectSize, rectSize/3)
        .attr
           fill: "#000",
           stroke: "none",
           cursor: "move"
        .drag(move, start, end)
        .click(click)
      )
    $(@).parent().hide()
  $('.editar-atributos button[type="submit"]').click () ->
    element = paper.getById $('.editar-atributos').data('element-id')
    element.data('fichas', $('.editar-atributos .fichas').val())
    $('.editar-atributos').hide()