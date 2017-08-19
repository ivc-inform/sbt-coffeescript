isc.ClassFactory.defineClass("HTMLPaneItem", isc.CanvasItem).addProperties
	height      : "*"
	width       : "*"
	autoDraw    : false
	showEdges   : true
	createCanvas: (form, item) ->
		if not @pane?
			@pane = isc.HTMLPaneSS.create
				autoDraw : @autoDraw
				width    : @width
				height   : @height
				showEdges: @showEdges
		@pane
