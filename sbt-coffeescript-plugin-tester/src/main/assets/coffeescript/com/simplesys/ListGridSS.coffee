isc.ListGrid.addProperties
#	"datetimeFormatter"        : ()->
#		"#{@getDate()}.#{@getMonth()}.#{@getShortYear()}"
		
	"canDragSelectText"        : true
	"getRowNumSelectedGridRecord": ->
		grid = @
		if grid.canSelectCells is true and grid.editByCell is true
			cell = grid.getFocusCell()
			if cell[0] >= 0
				rowNum = cell[0]

			if cell[1] >= 0
				colNum = cell[1]
		else
			rowNum = grid.getFocusRow()
			if rowNum < 0
				rowNum = null

		"rowNum": rowNum
		"colNum": colNum

	"setSelectionChanged": (func) ->
		exists = =>
			@selectionChangedQueue ?= []
			@selectionChangedQueue.filter((item) -> item is func).length > 0

		if isc.isA.Function(func) and not exists()
			@selectionChangedQueue.add(func)
		return

	"unsetSelectionChanged": (func) ->
		if func? and isc.isA.Function(func)
			res = @selectionChangedQueue.remove func
			if not res
				this.logWarn "Function: #{func.toString()} not removed."
		return

	"setSelectionUpdated": (func) ->
		exists = =>
			@selectionUpdatedQueue ?= []
			@selectionUpdatedQueue.filter((item) -> item is func).length > 0

		if isc.isA.Function(func) and not exists()
			@selectionUpdatedQueue.add(func)
		return

	"unsetSelectionUpdated": (func) ->
		if func? and isc.isA.Function(func)
			res = @selectionUpdatedQueue.remove func
			if not res
				this.logWarn "Function: #{func.toString()} not removed."
		return

	"selectFirstRecord": ->
		rec = @getRecord 0
		if rec?
			@selectSingleRecord rec
		@getSelectedRecord()

	"setMasterGrid": (grid, pkFieldNames) ->
		###console.log "setMasterGrid (grid: #{grid.getID()})"###
		if isc.isA.ListGridEditor(grid) or isc.isA.TreeGridEditor(grid)
			grid = grid.grid

		if isc.isA.ListGrid(grid)
			@masterGrid = grid
			if isc.isA.DataSource(@dataSource)
				forignKeyFields = @dataSource.getForignKeyFields()
	
				@masterGrid.setSelectionChanged? (record, state) =>
					masterSelectedRecords = @masterGrid.getSelectedRecords()
					
					@discardAllEdits()
	
					criteria = {}
					if pkFieldNames? and isc.isA.Object(pkFieldNames) and pkFieldNames.masterGridField? and pkFieldNames.detailGridField
						pkFieldNames = [pkFieldNames]
	
					if isc.isA.Array(pkFieldNames) and pkFieldNames.length > 0
						pkFieldNames. forEach (item) ->
							arrayRes = masterSelectedRecords.filter((rec) -> rec[item.masterGridField]?).map (rec) -> rec[item.masterGridField]
	
							if isc.isA.Array(arrayRes) and arrayRes.length > 0
								if arrayRes.length is 1
									criteria[item.detailGridField] = arrayRes[0]
								else
									criteria[item.detailGridField] = arrayRes
	
						if not isc.isA.emptyObject criteria
							@fetchData(
								criteria,
								if @selectFirstRecordAfterFetch is true then () => @selectFirstRecord() ; return)
						else if masterSelectedRecords.length > 0
							@logWarn1 "Criteria for MaterGrid not found", @getClassName()
					else
						for field, value of forignKeyFields
							if forignKeyFields[field].foreignKey.indexOf('.') isnt -1
								masterGridField = forignKeyFields[field].foreignKey.substring(forignKeyFields[field].foreignKey.lastIndexOf('.') + 1)
							else
								masterGridField = forignKeyFields[field]
	
							arrayRes = masterSelectedRecords.filter((rec) -> rec[masterGridField]?).map (rec) -> rec[masterGridField]
							if isc.isA.Array(arrayRes) and arrayRes.length > 0
								if arrayRes.length is 1
									criteria[field] = arrayRes[0]
								else
									criteria[field] = arrayRes
	
						if not isc.isA.emptyObject criteria
							@fetchData(
								criteria,
								if @selectFirstRecordAfterFetch is true then () => @selectFirstRecord(); return)
						else if masterSelectedRecords.length > 0
							@logWarn1 "Criteria for MaterGrid not found", @getClassName()
					return
			return

	"_getEditorWindow": (obj, fields, callback, requestProperties)->
		if not fields?
			fields = @editingFields

		if not requestProperties?
			if isc.isA.Object obj
				requestProperties =
					operationType: "add"
					data: obj
			else
				requestProperties = operationType: "add"

		requestProperties.operationType = "add" unless requestProperties.operationType

		updatedOperation = requestProperties.operationType is "update"

		form = isc.DynamicFormSS.create
				identifier: "#{@identifier}_DynamicForm_#{requestProperties.operationType}_#{if requestProperties.componentId? then requestProperties.componentId else ""}"
				dataSource: @dataSource
				numCols: 2
				height: "*"
				colWidths: [100, "*"]
				fields: fields

		okCancelPanel = isc.OkCancelFunctionPanel.create
			padding     : 5
			okCaption   : "Сохранить"
			ownerDestroy: false
			ownerHide   : false
			okFunction  : ->
				if (form.validate false)
					_save = =>
						@owner.markForDestroy()
						@okBtn.setDisabled true
						return

					form.saveData _save, requestProperties
				return
				
			functionButtonTitle: "Очистить все поля"
			functionFunction: ->
				form.clearErrors true
				form.clearValues()
				form.cancelEditing()
				return

		okCancelPanel.okBtn.showDisabledIcon = false
		setedFields = []

		if not updatedOperation and @masterGrid?
			forignKeyFields = @dataSource.getForignKeyFields()
			masterFields = @masterGrid.dataSource.getFieldNames(false)
			masterPKFields = @masterGrid.dataSource.getPrimaryKeyFieldNames()

			masterSelectedRecords = @masterGrid.getSelectedRecords()

			if (masterSelectedRecords.length isnt 1)
				okCancelPanel.okBtn.setDisabled true
			else
				okCancelPanel.okBtn.setDisabled false

				for field, value of forignKeyFields
					if forignKeyFields[field].foreignKey.indexOf('.') isnt -1
						masterGridField = forignKeyFields[field].foreignKey.substring(forignKeyFields[field].foreignKey.lastIndexOf('.') + 1)
					else
						masterGridField = forignKeyFields[field]

				if form.getField field
					form.setValue field, masterSelectedRecords[0][masterGridField]
					setedFields.push field

				masterFields.forEach (field) ->
					value = masterSelectedRecords[0][field]
					if not masterPKFields.contains(field) and form.getField(field)
						form.setValue(field, value)
						setedFields.push field
					return

				form.getItems().forEach (formItem) ->
					if not setedFields.contains(formItem.name)
						formItem.clearValue()
						return

		canvas = isc.ChainMasterDetail.create
			vertical: true
			members: [form, okCancelPanel]

		window = isc.WindowSS.create(
			isc.addProperties(
				{},
				isModal: true
				dismissOnEscape: true
				showMaximizeButton: false
				showMinimizeButton: false
				identifier: "#{@identifier}_Window_#{requestProperties.operationType}_#{if requestProperties.componentId? then requestProperties.componentId else ""}"
				title: if updatedOperation then "Редактирование записи..." else "Новая запись..."
				initWidget: ->
					@headerIconPath = if updatedOperation then "edit.png" else "insert.png"
					@Super("initWidget", arguments)
					@addItem canvas
					return
				, @editWindowProperties))

		okCancelPanel.owner = window
		#form.clearValues() if requestProperties.operationType is "add"
		return

	"startEditingNewInForm": (obj, fields, callback, requestProperties)->
		@_getEditorWindow obj, fields, callback, requestProperties
		return

	"startEditingInForm": (obj,fields, callback, requestProperties)->
		@_getEditorWindow obj, fields, callback, requestProperties
		return


isc.ClassFactory.defineInterface("GridEditorInterface").addInterfaceProperties
	"selectFirstRecord": ->
		@grid.selectFirstRecord()
		return
	"getDataSource"	                  : ->
		@grid.dataSource
	"setDataSource"	                  : (dataSource) ->
		@grid.setDataSource dataSource
		return
	"setSelectionChanged": (func) ->
		@grid.setSelectionChanged func
		return
	"unsetSelectionChanged": (func) ->
		@grid.unsetSelectionChanged func
		return
	"setSelectionUpdated": (func) ->
		@grid.setSelectionUpdated func
		return
	"unsetSelectionUpdated": (func) ->
		@grid.unsetSelectionUpdated func
		return
	"setForignFieldFields": (grid, masterGrid) ->
		if masterGrid?
			_masterGrid = masterGrid
		else
			_masterGrid = grid

		pkFields = _masterGrid.dataSource.getPrimaryKeyFieldsArray()

		fks = grid.dataSource.getForignKeyFields()

		for field of fks
			fk = fks[field].foreignKey
			if fk.indexOf('.') isnt -1
				foreignKey = fk.substring(fk.indexOf('.') + 1)
			else
				foreignKey = fk

			if foreignKey? and pkFields.contains foreignKey
				grid.dataSource.wildRecordJS = {} unless grid.dataSource.wildRecordJS
				grid.dataSource.wildRecordJS[field] = _masterGrid.getSelectedRecord()[foreignKey]
				lks = grid.dataSource.getLookupFields field
				for lk of lks
					grid.dataSource.wildRecordJS[lk] = _masterGrid.getSelectedRecord()[lk]
		return
	
	"selectRecordsByKey": (keyValues, newState, callback) ->
		if not isc.isA.Array(keyValues)
			keyValues = [keyValues]
		for keyValue in keyValues
			@selectSingleRecordByKey? keyValue, newState, callback

	"setSelectionChanged": (func) ->
		@grid.setSelectionChanged func
		return

	"getRecordIndex": (record) ->
		@grid.getRecordIndex record

	"selectRecordsSS": (records, newState) ->
		if not isc.isA.Array(records)
			records = [records]

		pkFields =  @grid.dataSource.getPrimaryKeyFieldsArray()

		getPkObj = (pkFields, records) ->
			records.map (record) ->
				res = {}
				pkFields.forEach (key) ->
					res[key] = record[key]
					return
				res

		keysObj = getPkObj pkFields, records
		keysObj.forEach (key) =>
			_selectedRecord = @grid.findByKey(key)
			if _selectedRecord?
				switch  @grid.selectionType
					when "multiple"
						@grid.selectRecord _selectedRecord, newState
					when "simple", "single"
						if @grid.selection?
							@grid.selectSingleRecord _selectedRecord, newState
						else
							@grid.selectRecord _selectedRecord, newState
					else
						undefined
			return

		return

	"initAdvancedFilter": ->
		if @showAdvancedFilter
			@filterBuilder = isc.FilterBuilderSS.create
				"allowEmpty": true
				"animateMembers": true
				"criteria": @getCriteria()
				"showResizeBar": true
				"animateMemberTime": 500
				"dataSource": @dataSource
				"showShadow": true

			toolStrip = isc.ToolStrip.create
				"members": [
					isc.ToolStripButton.create
						"click": =>
							a = @filterBuilder.getCriteria()

							b = @grid.getFilterEditorCriteria(true)

							c = isc.DataSourceSS.combineCriteriaSS(a, b, "left")

							###Чисто для отладки###
							###jsa = isc.JSONSS.encode a
							jsb = isc.JSONSS.encode b
							jsc = isc.JSONSS.encode c###

							@grid.fetchData(c)
							return
						"icon": "filter.png"
				]
				"width": 30

			@filterBuilder.addMember toolStrip

			@addMember @filterBuilder
			@addMember isc.SpacerItem.create
						   "height": 1
						   "width": "100%"

		@addMember @grid
		return

	"startEditingNewInForm": (obj, fields, callback, requestProperties)->
		@grid.startEditingNewInForm obj, fields, callback, requestProperties
		return

	"startEditingInForm": (obj, fields, callback, requestProperties)->
		@grid.startEditingInForm obj, fields, callback, requestProperties
		return



