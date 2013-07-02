# /javascripts/core.coffee
# Our main sketch object:
core_draw = (processing) ->

  # processing's "init" method:

  processing.setup = () ->
    resizeWindow()

    processing.println('PetriNet 0.0.1')

    processing.background()

    @manager = new Manager(processing)

    @teste = new Transicao(processing, {x: 200, y: 200})

    @popup = new Popup(processing)

    @objects = []

  # where the fun stuff happens:


  processing.mouseClicked = () ->
    if processing.mouseButton == processing.RIGHT
      # @popup.mouseClicked(processing.mouseX, processing.mouseY)
      # @objects.push(new Lugar(processing, {x: processing.mouseX, y: processing.mouseY, fichas: 5}))
      @objects.push(new Transicao(processing, {x: processing.mouseX, y: processing.mouseY}))
    else
      object.mouseClicked(processing.mouseX, processing.mouseY) for object in @objects

  processing.mousePressed = () ->
    object.startDrag(processing.mouseX, processing.mouseY) for object in @objects

  processing.mouseReleased = () ->
    processing.println(123)
    object.mouseReleased for object in @objects


  processing.mouseMoved = () ->
    if @popup.visible?
      @popup.mouseMoved(processing.mouseX, processing.mouseY)


  resizeWindow = () ->
    if $(document).height() > $(window).height()
      setupHeight = $(document).height()
    else
      setupHeight = $(window).height()
      $('canvas').width($(window).width())
      $('canvas').height(setupHeight)
      processing.size($(window).width(), setupHeight)

  processing.draw = () ->
    resizeWindow()
    @popup.draw()
    object.update(processing.mouseX, processing.mouseY) for object in @objects
    object.draw() for object in @objects
    # processing.println(object.dragged) for object in @objects


# wait for the DOM to be ready,
# create a processing instance...
$ ->
  canvas = document.getElementById "processing"
  processing = new Processing(canvas, core_draw)