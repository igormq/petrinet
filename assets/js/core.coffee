$ ->

  window.paper = Raphael('canvas', CANVAS_ALTURA, CANVAS_LARGURA)

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

  $(window).resize () ->
    paper.setSize($(window).width(),$(window).height())



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

  nl2br = (str, is_xhtml) ->
    breakTag = if (is_xhtml || typeof is_xhtml is 'undefined') then '<br />' else '<br>'
    "#{str}".replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2'

  $('#gerar-codigo').click () ->
    resultado = objetos.toArp().replace /\\r\\n/g, "<br />"
    $('#codigo .modal-body').html("<p>#{nl2br objetos.toArp()}</p>")
    $("#codigo").modal
      show: true