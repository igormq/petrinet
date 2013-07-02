# /javascripts/popup.coffee
class Popup
	@_largura: 120
	@_altura: 40

	constructor: (@processing) ->
		@visible = false

	draw: () ->
		if @visible
			@processing.rect(@position.x, @position.y, Popup._largura, Popup._altura)
			@processing.line(@position.x + 40, @position.y, @position.x + 40, @position.y + 40, Popup._largura, Popup._altura)
			@processing.line(@position.x + 80, @position.y, @position.x + 80, @position.y + 40, Popup._largura, Popup._altura)
			@processing.ellipse(@position.x + 20 , @position.y + 20, 20, 20)

	mouseInside: (mouseX, mouseY) ->
		if @visible == false
			return false

		mouseX >= @position.x  and  mouseX <= @position.x + Popup._largura and mouseY >= @position.y  and  mouseY <= @position.y + Popup._altura

	mouseClicked: (mouseX, mouseY, callback = null) ->
		if @visible and @mouseInside(mouseX, mouseY)
			callback? new Lugar(@processing, { x: mouseX, y: mouseY } ) if callback?
		else
			@position = new @processing.PVector(mouseX, mouseY)

		@visible = not @visible


	mouseMoved: (mouseX, mouseY) ->
			if not @mouseInside(mouseX, mouseY)
				@processing.cursor @processing.ARROW
			else
				@processing.cursor @processing.HAND