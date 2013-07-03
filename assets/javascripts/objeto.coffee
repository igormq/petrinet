# /javascripts/object.coffee

class Objeto
	@_id: 1

	constructor: (@processing, opts) ->
		@position = new @processing.PVector(opts.x, opts.y)
		@id = Objeto._id++
		@_selected = false
		@dragged = false
		@draggable = if opts.draggable? then opts.draggable else true

	mouseClicked: (mouseX, mouseY) ->
		if @mouseInside mouseX, mouseY
			@_selected = true
		else
			@_selected = false
		return @_selected

	startDrag: (mouseX, mouseY) ->
		if @draggable and @mouseInside(mouseX, mouseY) and not @dragged
			@dragged = true
			@_offsetX = mouseX - @position.x
			@_offsetY = mouseY - @position.y

	mouseReleased: () ->
		if @draggable
			@dragged = false

	update: (mouseX, mouseY) ->
		if @dragged
			@position.x = mouseX - @_offsetX
			@position.y = mouseY - @_offsetY
