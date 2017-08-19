isc.defineClass("DataSourceStructurer", isc.DataSourceSS).addProperties
	data   : []
	addMenu: (menu, parent, owner, separator_id, submenu_id, fromSubmenu) ->
		if isc.isA.Object(parent) is true then parent = parent.title

		if menu.data?
			menu.data.forEach (menuItem) =>
				if menuItem.isSeparator is true
					_id2 = "#{parent}_seperator_#{separator_id}"

					@.addNewData parent, _id2, "separator # #{separator_id}_menuItem", owner
					separator_id += 1
					return

				else if menuItem.submenu?
					_id = "#{parent}_#{menuItem.title}_menuItem"

					@.addNewData parent, _id, "menuItem: #{menuItem.title}_menuItem", owner
					@.addMenu menuItem.submenu, _id, owner, separator_id, submenu_id, true
					submenu_id += 1
					return

				else
					if fromSubmenu is false
						_id = "#{parent}_#{menuItem.title}_menuItem"
					else
						_id1 = "#{parent}_#{menuItem.title}_menuItem_submenu_#{submenu_id}"

					@.addNewData parent, _id1, "menuItem: #{menuItem.title}_menuItem", owner
					return

	addNewData: (parent, id, comment, canvas, owner) ->
		newRec = (identifier: id, pidentifier: parent, existing: false, comment: comment, canvas: canvas, owner: owner)

		if isc.isA.Canvas(canvas) is true
			for own prop, value of canvas
				if canvas?[prop]?._constructor? is "Menu" or isc.isA.Menu(canvas[prop]) is true
					menu = canvas[prop]
					separator_id = 0
					submenu_id = 0
					@addMenu menu, id, owner, separator_id, submenu_id

		if @data.filter ((item) -> item.identifier is newRec.identifier and item.pidentifier is newRec.pidentifier).length > 0
			message = "Dublicate identifier: " + newRec.identifier + " pidentifier: " + newRec.pidentifier + " been omitted."
			console.warn(message)
		else
			##console.log("identifier = " + newRec.identifier + " pidentifier: " + newRec.pidentifier)
			@addData newRec
			@data.add newRec
		return

	clientOnly: true
	dataFormat: "json"
	fields    : [
		(
			title     : "Родитель"
			name      : "pidentifier"
			foreignKey: "identifier"
			canSort   : false
		)
		(
			title     : "Идентификатор"
			primaryKey: true
			name      : "identifier"
			required  : true
			canSort   : false
		)
		(
			title   : "Назначение / Класс"
			name    : "comment"
			required: true
			canSort : false
		)
		(
			title  : "Свойства"
			name   : "propertiesView"
			canSort: false
		)
		(
			name    : "canvas"
			type    : "any"
			required: true
			hidden  : true
		)
		(
			name  : "properties"
			type  : "any"
			hidden: true
		)
	]

isc.defineClass("Structurer", isc.WindowSS).addProperties
	height            : 500
	width             : 500
	isModal           : false
	showMaximizeButton: true
	showMinimizeButton: false
	autoPosition      : false
	autoSize          : false
	canDragResize     : true
	identifier        : "DE34D33A-5CEE-7313-F91C-47B1868636C3"
	autoCenter        : false
	headerIconPath    : "structure.png"
	title             : "Структура вида..."
	initWidget        : ->
		@Super "initWidget", arguments

		if @view?
			@title = "Структура #{@view.getIdentifier()} (#{@view.getComment()})"

		@_getParentCanvasIdentifier = (canvas) ->
			parent = canvas.getParentCanvas()
			if parent?
				parent.getIdentifier()

		@_addSelfCanvas = (child) ->
			if isc.isA.Canvas(child) is true
				@dataSource.addNewData(@_getParentCanvasIdentifier(child), child.getIdentifier(), child.getComment(), child, @treeGrid)
			return

		@_addChildrenCanvas = (canvas) ->
			if canvas.children? and canvas.children.length > 0
				canvas.children.forEach (child) ->
					@_addSelfCanvas(child)
					@_addChildrenCanvas(child)
			return

		@_getTree = ->
			if isc.isA.Canvas(@view) is true

				parent = @view.getParentCanvas()
				while parent
					@_addSelfCanvas(parent)
					parent = parent.getParentCanvas()

				@_addSelfCanvas(@view)
				@_addChildrenCanvas(@view)
			return

		@_menu = isc.MenuSS.create
			"items"   : [
				"keys"    : [
					"ctrlKey": true
					"keyName": "P"
				]
				"title"   : "Свойства для администрирования ..."
				"click"   : -> simpleSyS.PropertiesEditor = @_menu.record; return
				"icon"    : "parameters.png"
				"keyTitle": "Ctrl+P"
				"enableIf": => @treeGrid.getSelectedRecord()
			]
			"autoDraw": false

		@treeGrid = isc.TreeGridEditor.create
			identifier          : "5758AE4B-EFC5-AD3D-D1F7-3FE4ABEF805F"
			selectionAppearance : "checkbox"
			showSelectedStyle   : false
			showPartialSelection: true
			cascadeSelection    : true
			height              : "100%"
			width               : "100%"
			dataSource          : @dataSource
			showFilterEditor    : false
			showDropIcons       : false
			editEvent           : "click"
			nodeIcon            : "part_widget.png"
			folderIcon          : "widget.png"
			autoFetchData       : true
			contextMenu         : @_menu
			wrapCells           : true
			_restoreLastBorder  : ->
				if @lastBorderData?
					window.clearInterval(@lastBorderData.intervalID)
					@lastBorderData.canvas.setBorder(@lastBorderData.border)
					delete @lastBorderData
				return

			rowClick: (record) ->
				@_restoreLastBorder()
				if isc.EventHandler.shiftKeyDown() is true
					simpleSyS.PropertiesEditor = record
				else if isc.isA.Canvas(record.canvas) is true
					treeGrid.lastBorderData = record.canvas.setBlinkBorder1("2px dotted red")
				return

			rowContextClick: (record, rowNum, colNum) ->
				@_menu.record = record
				@_restoreLastBorder()
				return

			dataProperties:
				dataArrived: =>
					@openAll()

					existsEnabledProperties = (properties) =>
						not isc.isA.emptyArray(properties) and (properties.filter (item) -> simpleSyS.V4Admin[item]).length > 0

					if @result?
						@result.forEach (item) ->
							node = that1.findById(item.identifier)
							if node?
								if isc.isA.emptyArray(item.properties) is false
									treeGrid.selectRecord node
									node.properties = item.properties
									node.propertiesView = isc.JSON.encode(item.properties, prettyPrint: false)

							fields: [
								(name: "pidentifier")
								(name: "identifier")
								(name: "comment", length: 1000)
								(name: "propertiesView", length: 1000)
							]
					return

		@onDestroy = ->
			@_restoreLastBorder()
			@markForDestroy()
			return

		@_ed = isc.OkCancelPanel.create
			height       : 35
			owner        : @
			disabledOk   : true
			cancelCaption: "Закрыть"
			okCaption    : "Применить"
			okFunction   : ->
				selectedIDS = @treeGrid.getSelectedRecords().filter((record) -> record.properties).map (record) ->
					pidentifier: record.pidentifier
					identifier : record.identifier
					comment    : record.comment
					properties : record.properties

				isc.OfflineSS.putToBase @view.getIdentifier(),
				                       selectedIDS
				return

		@addItems [@treeGrid, @_ed]

		@_getTree()
		return

