# /javascripts/object.coffee

class Objeto
	@_id: 1

	contructor: (@processing, opts) ->
		@position = new @processing.PVector(opts.x, opts.y)
		@id = Objeto._id++
		@_selected = false