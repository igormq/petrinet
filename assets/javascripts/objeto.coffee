# /javascripts/object.coffee

class Objeto
	@_id: 1

	constructor: (@processing, opts) ->
		@position = new @processing.PVector(opts.x, opts.y)
		@id = Objeto._id++
		@_selected = false