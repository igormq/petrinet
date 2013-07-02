# /javascripts/lugar.coffee

class Lugar extends Objeto
	@_radius: 15

	constructor: (processing, opts) ->
		super processing, opts
<<<<<<< HEAD
		@fichas = 0
=======
		@fichas = opts.fichas
>>>>>>> 899588ab6a6d792c7ec3d23063aa144c43a1765f

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
