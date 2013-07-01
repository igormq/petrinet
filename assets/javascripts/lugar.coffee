# /javascripts/lugar.coffee

class Lugar
	@_id: 1
	@_radius: 30

	constructor: (@processing, opts) ->
		@position = new @processing.PVector(opts.x, opts.y)
		@id = Lugar._id++
		this.draw()

	draw: () ->
		@processing.ellipse(@position.x, @position.y, Lugar._radius, Lugar._radius);


	mouseClicked: (mouseX, mouseY) ->


