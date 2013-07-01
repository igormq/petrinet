# /javascripts/lugar.coffee

class Lugar extends Objeto
	@_radius: 30

	constructor: (@processing, opts) ->
		super @processing, opts

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