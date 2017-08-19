isc.defineClass("WindowWrapper", isc.WindowSS).addProperties
	height            : 700
	width             : 500
	isModal           : true
	showMaximizeButton: false
	showMinimizeButton: false
	canDragResize     : true
	autoPosition      : true
	initWidget        : ->
		@Super "initWidget", arguments

		ed = isc.OkCancelFunctionPanel.create
			height          : 35
			owner           : @
			functionFunction: =>
				@wrappedComponent?.contextMenu?.showContextMenu?()

		@addItems [@wrappedComponent, ed]
		return
