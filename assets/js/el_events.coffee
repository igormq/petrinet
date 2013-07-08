@transicaoDblclick = () ->
  $('.editar-pesos').css 'top', "#{@attr('y') + @attr('height')/2}px"
  $('.editar-pesos').css 'left', "#{@attr('x') + @attr('width')/2}px"
  $('.editar-pesos').data('element-id', "#{@id}")
  $('.editar-pesos .content').html('')
  mostrar = false
  if @data('linefrom')?
    mostrar = true
    @data('linefrom').forEach (e) ->
      $("#vai-para .content").append("<label>#{e.data('elto').data('nome')}:</label><input type=\"text\" class=\"input-mir\" data-element='#{e.data('elto').id}' data-type='linefrom' value='#{e.data('peso')}'/>")
  if @data('lineto')?
    mostrar = true
    @data('lineto').forEach (e) ->
      $("#vem-de .content").append("<label>#{e.data('elfrom').data('nome')}:</label><input type=\"text\" class=\"input-mir\" data-element='#{e.data('elfrom').id}' data-type='lineto' value='#{e.data('peso')}'/>")
  if mostrar
    $(".editar-pesos").show()

@dblclick = () ->
  $('.editar-atributos').show()
  $(".editar-atributos input[type='text'].fichas").val(@data('fichas'))
  $('.editar-atributos').css 'top', "#{@attr('cy')}px"
  $('.editar-atributos').css 'left', "#{@attr('cx')}px"
  $('.editar-atributos').data 'element-id', "#{@id}"


@click = () ->
  $('.menu').hide()
  $('.editar-atributos').hide()
  $('.editar-pesos').hide()
  if @ox != @attr("x") and @oy != @attr("y")
    return false
  dimensions = @getBBox()
  x = dimensions.x + dimensions.width/2
  y = dimensions.y + dimensions.height/2
  #Está no segundo click?
  if paper.canvas.onmousemove?
    #Caso o segundo click seja em um objeto diferente do clicado na primeira vez
    if (@id != window.oldid) && (@type != paper.getById(window.oldid).type)
      connected = false
      if @data('lineto')?
        @data('lineto').forEach (e) =>
          if e.data("elfrom").id == window.oldid
            connected = true
      console.log("connected is #{connected}")
      if !connected
        console.log(@type)
        console.log(paper.getById(window.oldid).type)
        console.log(@type != paper.getById(window.oldid).type)
        ang = 360 - Raphael.angle(x,y,window.oldx,window.oldy) #Acerta o ângulo para começar em 0 a partir do eixo X
        ang = ang * Math.PI / 180 #Conversão para radianos
        finalX = x - dimensions.width*Math.cos(ang)/2
        finalY = y + dimensions.height*Math.sin(ang)/2
        window.band.attr({path: "M #{window.oldx} #{window.oldy}L #{finalX} #{finalY}"})
        console.log("M #{window.oldx} #{window.oldy}L #{finalX} #{finalY}")
        #De onde a linha vem
        window.band.data('elfrom', paper.getById(window.oldid))
        #Para onde a linha vai
        window.band.data('elto', @)
        window.band.data('peso', 1) #Peso padrão da linha
        tempPoint = window.band.getPointAtLength(window.band.getTotalLength()/2)
        tempPeso = window.paper.text(tempPoint.x, tempPoint.y, 1) #Gera o texto do peso da linha
          .attr
            fill: "#fb5c47",
            stroke: "#fb5c47",
            "stroke-width": 1,
            "font-size": 20
        tempPeso.node.style.pointerEvents = "none" #O texto não deve afetar a interação
        window.band.data("texto", tempPeso)
        oldtemp = paper.getById(window.oldid)
        #Verifica se já existe um set
        #Se ele existir, adiciona a linha ao set existente
        if oldtemp.data('linefrom')?
          console.log("Adicionando linha id#{window.band.id} no set do obj de saida id#{window.oldid}")
          oldtemp.data('linefrom').push(window.band)
        #Se o set não existir, cria um set com a linha
        else
          console.log("Criando set com a linha id #{window.band.id} para o obj de saida id #{window.oldid}")
          newset = paper.set()
          newset.push(window.band)
          oldtemp.data('linefrom',newset)
        #Mesma coisa para o elemento de entrada da linha
        if @data('lineto')?
          console.log("Adicionando linha id#{window.band.id} no set do obj de entrada id#{@id}")
          @data('lineto').push(window.band)
        else
          console.log("Criando set com a linha id #{window.band.id} para o obj de entrada id #{@id}")
          newset = paper.set()
          newset.push(window.band)
          @data('lineto',newset)
      else
        window.band.remove() #A linha será excluída caso já exista outra que faça a mesma conexão
    #A linha será anulada caso o mesmo objeto seja clicado duas vezes
    else
      window.band.remove()
  window.band = paper.path("M 0 0").attr({"stroke-width": 5, "arrow-end": "block-narrow-short"})
  window.band.toBack() #Linha deve ficar atrás dos outros elementos
  window.bg.toBack() #Mantém o plano de fundo atrás de tudo
  window.band.node.style.pointerEvents = "none"
  if not paper.canvas.onmousemove?
    paper.canvas.onmousemove = (e) ->
      window.band.attr({path: "M #{x} #{y}L #{e.clientX} #{e.clientY}"})
    @undrag()
  else
    paper.canvas.onmousemove = null
    paper.getById(window.oldid).drag(move, start, end)
  window.oldid = @id
  window.oldx = x
  window.oldy = y

@removeEl = (mouse) ->
  console.log("mouse.which is #{mouse.which}")
  if (mouse.which == 3)
    deleteEl @

@deleteEl = (obj) ->
  if obj.data("linefrom")?
    obj.data("linefrom").forEach (line) =>
      line.data('elto').data("lineto").exclude(line) #Exclui a linha da lista de linhas ligadas do outro elemento
      line.remove()
  if obj.data("lineto")?
    obj.data("lineto").forEach (line) =>
      line.data('elfrom').data("linefrom").exclude(line) #Exclui a linha da lista de linhas ligadas do outro elemento
      line.remove()
  if obj.data("textref")?
    obj.data("textref").remove()
  if obj.data("nomeref")?
    obj.data("nomeref").remove()
  objetos.exclude(obj)
  obj.remove()