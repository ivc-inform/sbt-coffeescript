isc.defineClass("ArraySS", isc.Array)

isc.addMethods Array.prototype, {
	getX: -> if @length > 0 then @[0] else undefined
	getY: -> if @length > 1 then @[1] else undefined

	setX: (x) -> @[0] = x; x
	setY: (y) -> @[1] = y; y

	Exists: (index) => if @[index]? then true else false
	notExists: (index) => @exists index

	getAppex: () -> @

	getBoundingBox: () -> [@[0][0], @[0][1], @[2][0], @[2][1]]

	getRect: () ->
		left: @[0][0]
		top: @[0][1]
		width: @[2][0] - @[0][0]
		height: @[2][1] - @[0][1]

	getRect1: () ->
		left: @[0]
		top: @[1]
		width: @[2]
		height: @[3]

	remove: (obj, pos, endPos, comparator) ->
		index = @indexOf obj, pos, endPos, comparator
		if index is - 1
			false
		else
			@removeAt(index)
			true

}



