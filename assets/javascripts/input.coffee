# /javascripts/input.coffee
class Input
	@_width: 120
	@_height: 40
	constructor: (@processing, opts) ->
		@position = new @processing.PVector(opts.x, opts.y)

	draw: () ->
		@processing.rect(@position.x, @position.y, Input._width, Input._height)
		@processing.line(@position.x + 40, @position.x + 40, @position.y, @position.y + 40, Input._width, Input._height)
		@processing.ellipse(@position.x + 20 , @position.y + 20, 20, 20)

	mouseMoved: () ->

	mouseHover: () ->

	mouseClicked: () ->

