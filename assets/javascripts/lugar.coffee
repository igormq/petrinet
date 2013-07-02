# /javascripts/lugar.coffee

class Lugar extends Objeto
	@_radius: 15

	constructor: (processing, opts) ->
		super processing, opts
		@fichas = 0

	draw: () ->
		if !@_selected
			@processing.fill(255,0,0)
		else
			@processing.fill(0,0,255)
		@processing.ellipse(@position.x, @position.y, Lugar._radius * 2, Lugar._radius * 2);
		@._drawFichas()

	_drawFichas: () ->
		@processing.fill(0)
		@processing.textSize(20)
		@processing.textAlign(@processing.CENTER, @processing.CENTER)
		@processing.text(@fichas, @position.x, @position.y)

	mouseInside: (mouseX, mouseY) ->
		@processing.dist(mouseX, mouseY, @position.x, @position.y) <= Lugar._radius
