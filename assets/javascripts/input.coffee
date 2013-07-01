# /javascripts/input.coffee
class Input
	@_largura: 120
	@_altura: 40

	constructor: (@processing) ->
		@visible = false

	draw: () ->
		if @visible
			@processing.rect(@position.x, @position.y, Input._largura, Input._altura)
			@processing.line(@position.x + 40, @position.y, @position.x + 40, @position.y + 40, Input._largura, Input._altura)
			@processing.line(@position.x + 80, @position.y, @position.x + 80, @position.y + 40, Input._largura, Input._altura)
			@processing.ellipse(@position.x + 20 , @position.y + 20, 20, 20)

	mouseInside: (mouseX, mouseY) ->
		if @.visible == false
			return false

		if mouseX >= @position.x  and  mouseX <= @position.x + Input._largura and mouseY >= @position.y  and  mouseY <= @position.y + Input._altura
			true
		else
			false

	mouseClicked: (mouseX, mouseY) ->
			@visible = not @visible
			@position = new @processing.PVector(mouseX, mouseY)


	mouseMoved: (mouseX, mouseY) ->
			if not @.mouseInside(mouseX, mouseY)
				@visible = false