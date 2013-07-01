# /javascripts/lugar.coffee

class Lugar
	@_id: 1
	@_radius: 30

	constructor: (@processing, opts) ->
		@position = new @processing.PVector(opts.x, opts.y)
		@id = Lugar._id++
		@_selected = false
		this.draw()

	draw: () ->
		if !@_selected
			@processing.fill(255,0,0)
		else
			@processing.fill(0,0,255)
		@processing.ellipse(@position.x, @position.y, Lugar._radius, Lugar._radius);


	mouseClicked: (mouseX, mouseY) ->
		if (@processing.dist(mouseX, mouseY, @position.x, @position.y) <= Lugar._radius)
			@_selected = true 
		else
			@_selected = false