# /javascripts/core.coffee
# Our main sketch object:
core_draw = (processing) ->

  processing.setup = () ->
    resizeWindow()

    processing.println('PetriNet 0.0.1')

    processing.background()

    @manager = new Manager(processing)

    @teste = new Transicao(processing, {x: 200, y: 200})

    @popup = new Popup(processing)

    @objects = []


  processing.mouseClicked = () ->
    if !(true in (object.mouseInside(processing.mouseX, processing.mouseY) for object in @objects))
      if processing.mouseButton == processing.RIGHT
        @popup.mouseClicked processing.mouseX, processing.mouseY
      else
        if @popup.visible
          @popup.mouseClicked processing.mouseX, processing.mouseY, (object) =>
            @objects.push(object) if object?
    else if processing.mouseButton == processing.LEFT
      object.mouseClicked(processing.mouseX, processing.mouseY) for object in @objects

  processing.mousePressed = () ->
    object.startDrag(processing.mouseX, processing.mouseY) for object in @objects when object.draggable

  processing.mouseReleased = () ->
    object.mouseReleased() for object in @objects

  processing.mouseDragged = () ->
    object.update(processing.mouseX, processing.mouseY) for object in @objects

  processing.mouseMoved = () ->
    if @popup.visible?
      @popup.mouseMoved(processing.mouseX, processing.mouseY)
    else
      if (true in (object.mouseInside(processing.mouseX, processing.mouseY) for object in @objects))
        processing.cursor(processing.HAND)
      else
        processing.cursor(processing.ARROW)


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
    object.draw() for object in @objects
    # processing.println(object.dragged) for object in @objects


# wait for the DOM to be ready,
# create a processing instance...
$ ->
  canvas = document.getElementById "processing"
  processing = new Processing(canvas, core_draw)