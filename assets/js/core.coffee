$ ->

  larguraWindow =  $(window).innerWidth()/2
  alturaWindow = $(window).innerHeight()*3/4
  window.paper = Raphael('canvas', larguraWindow, alturaWindow)
  window.bg = window.paper.path("M 0 0 L #{larguraWindow} 0 L #{larguraWindow} #{alturaWindow} L 0 #{alturaWindow} Z") #Gera o quadrado do tamanho do fundo
    .attr
      "stroke-width": 5
      stroke: "#4c4c4c"
      fill: "#f0f0f0"
  window.bg.node.style.pointerEvents = "none" #Para que se possa clicar sobre o fundo

  paper.ca.x = (num) ->
    if @type == 'circle'
      return { cx: num + @attr('r') }
    { x: num }
  paper.ca.y = (num) ->
    if @type == 'circle'
      return { cy: num + @attr('r') }
    { y: num }

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

  window.objetos = paper.set()

  # $(window).resize () ->
  #   paper.setSize($(window).width(),$(window).height())



  #previnir o click com o botao direito
  $(paper.canvas).bind "contextmenu", (e) ->
    $('.menu').hide()
    $('.editar-atributos').hide()
    e.preventDefault()


  $('.menu .btn').click () ->
    if $(@).hasClass('lugar')
      objetos.push(paper.lugar(+$(@).parent().data('x'), +$(@).parent().data('y')))
    else if $(@).hasClass('transicao')
      objetos.push(paper.transicao(+$(@).parent().data('x'), +$(@).parent().data('y')))
    $(@).parent().hide()
  $('.editar-atributos button[type="submit"]').click () ->
    element = paper.getById $('.editar-atributos').data('element-id')
    element.data('fichas', parseInt($('.editar-atributos .fichas').val()))
    element.data("textref").attr({text: element.data("fichas")})
    $('.editar-atributos').hide()