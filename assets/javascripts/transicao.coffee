# /javascripts/transicao.coffe

class Transicao extends Objeto
	@_largura: 20
	@_altura: 10

	constructor: (processing, opts) ->
		super processing, opts

	draw: () ->
		if !@_selected
			@processing.fill(255,0,0)
		else
			@processing.fill(0,0,255)
		@processing.rect(@position.x, @position.y, Transicao._largura, Transicao._altura)

	mouseInside: (mouseX, mouseY) ->
		mouseX >= @position.x - Transicao._largura/2 && mouseX <= @position.x + Transicao._largura/2 && mouseY >= @position.y - Transicao._altura && mouseY <= @position.y + Transicao._altura