# /javascripts/lugar.coffee

class Lugar
	@_id: 1
	@_radius: 40

	constructor: (@processing, opts) ->
		@position = new @processing.PVector(opts.x, opts.y)
		@id = Lugar._id++
		@fichas = 0
		@.draw()

	draw: () ->
		@processing.fill(@processing.white)
		@processing.ellipse(@position.x, @position.y, Lugar._radius, Lugar._radius)
		@._drawFichas()

	_drawFichas: () ->
		@processing.fill(0)
		@processing.textSize(20)
		@processing.textAlign(@processing.CENTER, @processing.CENTER)
		@processing.text(@fichas, @position.x, @position.y)

	mouseClicked: (mouseX, mouseY) ->


