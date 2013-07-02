# /javascripts/object.coffee

class Objeto
	@_id: 1

	constructor: (@processing, opts) ->
		@position = new @processing.PVector(opts.x, opts.y)
		@id = Objeto._id++
		@_selected = false

	mouseClicked: (mouseX, mouseY) ->
		if @.mouseInside mouseX, mouseY
			@_selected = true
		else
			@_selected = false
		return @_selected