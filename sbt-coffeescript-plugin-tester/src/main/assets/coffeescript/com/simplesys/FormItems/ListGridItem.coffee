isc.defineClass("ListGridItem", isc.CanvasItem).addProperties
	height              : "*"
	width               : "*"
	autoFetchData       : true
	fixedRecordHeights  : true
	wrapCells           : false
	autoFitWidthApproach: "title"
	canEdit             : true
	autoDraw            : false
	selectionAppearance : "rowStyle"
	canResizeFields     : true
	findByKey: (keyValue) -> @grid.findByKey keyValue
	isSelected: (record) -> @grid.isSelected record
	deselectRecord : (record) ->
		@grid.deselectRecord record
		return
	deselectRecords : (records) ->
		@grid.deselectRecords records
		return
	deselectAllRecords: ->
		@grid.deselectAllRecords()
		return
	selectRecord : (record) ->
			@grid.selectRecord record
			return
	selectRecords : (records) ->
		@grid.selectRecords records
		return
	getSelectedRecord: ->
		@grid.getSelectedRecord()
	getSelectedRecords: ->
		@grid.getSelectedRecords()
	getSelection: ->
		@grid.getSelection()
	getDataSource	                  : ->
		@grid.getDataSource()
	createCanvas        : (form, item) ->
		if not @grid?
			@grid = isc.ListGridEditor.create
				canEdit              : @canEdit
				autoDraw             : @autoDraw
				width                : @width
				height               : @height
				dataSource           : @dataSource
				fields               : @fields
				autoFetchData        : @autoFetchData
				fixedRecordHeights   : @fixedRecordHeights
				autoFitWidthApproach : @autoFitWidthApproach
				cellChanged          : @cellChanged
				selectionUpdated     : @selectionUpdated
				selectionChanged     : @selectionChanged
				wrapCells            : @wrapCells
				canResizeFields      : @canResizeFields
				selectionType        : @selectionType
				selectionAppearance  : @selectionAppearance
				initialSort          : @initialSort

			@unsetSelectionUpdated = (func) =>
				@grid.unsetSelectionUpdated func
				return

			@setSelectionUpdated = (func) =>
				@grid.setSelectionUpdated func
				return

			@unsetSelectionChanged = (func) =>
				@grid.unsetSelectionChanged func
				return

			@setSelectionChanged = (func) =>
				@grid.setSelectionChanged func
				return

			@fetchData = (criteria, callback, requestProperties) =>
				@grid.fetchData criteria, callback, requestProperties
				return

		if not form.gridItem?
			form.gridItem = @grid;
		else if isc.isA.Array(form.gridItem) is false
			form.gridItem.add @grid
		else
			form.gridItem = [form.gridItem]
			form.gridItem.add @grid

		if @dataFetchMode?
			@grid.dataFetchMode = @dataFetchMode
		@grid
