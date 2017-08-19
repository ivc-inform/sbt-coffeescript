isc.defineClass("JoinJSCanvas", isc.Canvas).addProperties
	"suffix": "_joinJSCanvas"
	"redrawOnResize": false
	"_getNewID" : () ->
		"#{@getID()}#{@suffix}"

	"getInnerHTML": ()->
		"<div ID=#{@_getNewID()}></div>"
	"setJoinJSFunc": (func)->
		@joinJSFunc = func
		@
	"draw": () ->
		if @.readyToDraw()
			@Super "draw", arguments

			if isc.isA.Function @joinJSFunc
				@joinJSFunc(@_getNewID())
			else if isc.isA.String @joinJSFunc
				@evaluate @joinJSFunc, "anchor": "##{@_getNewID()}"
			@
		else
			@
