
@dblclick = () ->
    $('.editar-atributos').show()
    $(".editar-atributos input[type='text'].fichas").val(@data('fichas'))
    $('.editar-atributos').css 'top', "#{@attr('cy')}px"
    $('.editar-atributos').css 'left', "#{@attr('cx')}px"
    $('.editar-atributos').data 'element-id', "#{@id}"


@click = () ->
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
        ang = 360 - Raphael.angle(x,y,oldx,oldy) #Acerta o ângulo para começar em 0 a partir do eixo X
        ang = ang * Math.PI / 180 #Conversão para radianos
        finalX = x - dimensions.width*Math.cos(ang)/2
        finalY = y + dimensions.height*Math.sin(ang)/2
        window.band.attr({path: "M #{oldx} #{oldy}L #{finalX} #{finalY}"})
        #De onde a linha vem
        window.band.data('elfrom', paper.getById(window.oldid))
        #Para onde a linha vai
        window.band.data('elto', @)
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
  window.band.node.style.pointerEvents = "none"
  if not paper.canvas.onmousemove?
    paper.canvas.onmousemove = (e) ->
      window.band.attr({path: "M #{x} #{y}L #{e.clientX} #{e.clientY}"})
    @undrag()
  else
    paper.canvas.onmousemove = null
    paper.getById(window.oldid).drag(move, start, end)
  window.oldid = @id
