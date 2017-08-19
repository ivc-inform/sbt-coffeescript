isc.defineClass("DrawItemTileCf", isc.SimpleTile).addProperties
	initWidget: ->
		@Super "initWidget", arguments

		@drawPane = isc.DrawPane.create
			autoDraw: false
			width: "100%"
			height: "100%"

		@addChild @drawPane

		@setLogPriority @getClassName(), isc.Log.DEBUG

		return

	getInnerHTML: -> "&nbsp;"

	drawRecord: (record) ->
		tilePalette = @tileGrid

		drawItem = tilePalette.makeEditNode(record).liveObject

		if not isc.isAn.Instance(drawItem)
			if drawItem._constructor?
				drawItem = isc[drawItem._constructor].create isc.addProperties {}, drawItem, autoDraw: false
				@drawPane.addDrawItem drawItem
			else
				@logError "Record is not drawItem and unknown _constructor"
		else
			@drawPane.addDrawItem drawItem
		return

	draw: ->
		ret = @Super "draw", arguments
		record = @getRecord()
		#@logDebug "draw: (#{js_beautify(isc.JSON.encode record)})"
		@drawRecord record
		ret

	redraw: ->
		drawPane = @drawPane
		record = @getRecord()

		if record isnt @record
			drawPane.erase()

			@drawRecord record
			@record = record

		@Super "redraw", arguments
		return
