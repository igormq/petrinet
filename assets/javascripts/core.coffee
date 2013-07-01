# /javascripts/core.coffee
# Our main sketch object:
core_draw = (processing) ->

  # processing's "init" method:
  @_objects = []

  processing.setup = () ->
    resizeWindow()

    processing.println('PetriNet 0.0.1')

    processing.background()

    @manager = new Manager(processing)

  # where the fun stuff happens:
  processing.draw = () ->
    resizeWindow()
    object.draw() for object in @_objects

  processing.mouseClicked = () ->
    @_objects.push(new Lugar(processing, {x: processing.mouseX, y: processing.mouseY }))


  resizeWindow = () ->
    if $(document).height() > $(window).height()
      setupHeight = $(document).height()
    else
      setupHeight = $(window).height()
      $('canvas').width($(window).width())
      $('canvas').height(setupHeight)
      processing.size($(window).width(), setupHeight)


# wait for the DOM to be ready,
# create a processing instance...
$ ->
  canvas = document.getElementById "processing"
  processing = new Processing(canvas, core_draw)