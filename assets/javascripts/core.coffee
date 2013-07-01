# /javascripts/core.coffee
# Our main sketch object:
core_draw = (processing) ->

  # processing's "init" method:

  processing.setup = () ->
    resizeWindow()

    processing.println('PetriNet 0.0.1')

    processing.background()

    @manager = new Manager(processing)

    @input = new Input(processing)

    @objects = []

  # where the fun stuff happens:


  processing.mouseClicked = () ->
    if processing.mouseButton == processing.RIGHT
      @input.mouseClicked(processing.mouseX, processing.mouseY)
    else
      object.mouseClicked(processing.mouseX, processing.mouseY) for object in @objects


  processing.mouseMoved = () ->
    if @input.visible?
      @input.mouseMoved(processing.mouseX, processing.mouseY)


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
    @input.draw()
    object.draw() for object in @objects


# wait for the DOM to be ready,
# create a processing instance...
$ ->
  canvas = document.getElementById "processing"
  processing = new Processing(canvas, core_draw)