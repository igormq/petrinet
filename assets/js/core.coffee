$ ->

  larguraWindow =  $(window).innerWidth()
  alturaWindow = $(window).innerHeight()*3/4
  window.paper = Raphael('canvas', larguraWindow, alturaWindow)
  window.bg = window.paper.path("M 0 0 L #{larguraWindow} 0 L #{larguraWindow} #{alturaWindow} L 0 #{alturaWindow} Z") #Gera o quadrado do tamanho do fundo
    .attr
      "stroke-width": 2
      stroke: "#d8d8d8"
      fill: "#fafafa"
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
    if $('.editar-pesos').is ':visible'
      $('.editar-pesos').hide()
    else if not paper.canvas.onmousemove?
      if $('.editar-atributos').is ':visible'
        $('.editar-atributos').hide()
      else if $('.editar-pesos').is ':visible'
        $('.editar-pesos').hide()
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

  $('.editar-pesos button[type="submit"]').click () ->
    element = paper.getById($('.editar-pesos').data('element-id'))
    if element.data('linefrom')?
      element.data('linefrom').forEach (e) ->
        e.data('peso', parseInt($(".editar-pesos input[data-element='#{e.data('elto').id}'][data-type='linefrom']").val()))
        e.data("texto").attr({text: e.data("peso")}) # Atualiza o texto
    if element.data('lineto')?
      element.data('lineto').forEach (e) ->
        e.data('peso', parseInt($(".editar-pesos input[data-element='#{e.data('elfrom').id}'][data-type='lineto']").val()))
        e.data("texto").attr({text: e.data("peso")}) # Atualiza o texto
    $('.editar-pesos').hide()

  nl2br = (str, is_xhtml) ->
    breakTag = if (is_xhtml || typeof is_xhtml is 'undefined') then '<br />' else '<br>'
    "#{str}".replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2'

  $('#gerar-codigo').click () ->
    resultado = objetos.toArp().replace /\\r\\n/g, "<br />"
    $('#codigo .modal-body').html("<p>#{nl2br objetos.toArp()}</p>")
    $("#codigo").modal
      show: true

  $('#limpar-sketch').click () ->
    temp = bg.next
    console.log("temp id is #{temp.id}")
    while temp.next?
      temp2 = temp
      temp = temp2.next
      temp2.remove()
    temp.remove()
    window.numP = 1
    window.numT = 1
    objetos.clear()