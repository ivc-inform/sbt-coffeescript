isc.defineClass("ListGridEditor", isc.VLayoutSS, isc.GridEditorInterface).addProperties
	"canDragSelectText"          : true
	"autoFitFieldWidths"         : false
	"canAutoFitWidth"            : false
	"hoverWidth"                 : 300
	"dataFetchMode"              : "paged"
	"canResizeFields"            : true
	"selectionType"              : "single"
	"findByKey"                  : (keyValue) -> @grid.findByKey keyValue
	"removeData"                 : (removeRecord, callback, requestProperties) ->
		@grid.removeData removeRecord, callback, requestProperties
		return
	"saveAllEdits"               : (rows, saveCallback) ->
		@grid.saveAllEdits(rows, saveCallback)
		return
	"recordComponentPoolingMode" : "viewport"
	"selectAllRecords"           : (visibleNodesOnly)->
		@grid.selectAllRecords visibleNodesOnly
		return
	"showAllRecords"             : false
	"refreshRecordComponent"     : (rowNum, colNum) ->
		@grid.refreshRecordComponent recordDate, colNum
		return
	"applyRecordData": (recordDate) ->
		@grid.applyRecordData recordDate
		return
	"invalidateRecordComponents": () ->
		@grid.invalidateRecordComponents()
		return
	"selectSingleRecordByKey"    : (keyValue, newStyle, callback) ->
		record = @findByKey keyValue, newStyle
		if record?
			@selectRecord record
			isc.Class.fireCallback callback
		else
			@deselectAllRecords()
		record
	"selectFirstRecordAfterFetch": true
	"fetchData"                  : (criteria, callback, requestProperties) ->
		if @useClientFilteringSorting is false
			_callback = (dsResponse, data, dsRequest) =>
				@grid.selectFirstRecord() if @selectFirstRecordAfterFetch
				@fireCallback(callback, "dsResponse, data, dsRequest", [dsResponse, data, dsRequest])
				return
			
			@grid.filterData criteria, _callback, requestProperties
			@filterBuilder?.setCriteria criteria
		else
			_callback = (dsResponse, data, dsRequest) =>
				resultSet = isc.ResultSet.create
					dataSource: @dataSource
					allRows   : data
				
				@grid.setData resultSet
				@fireCallback(callback, "dsResponse, data, dsRequest", [dsResponse, data, dsRequest])
				return
			
			@dataSource.filterData criteria, _callback, requestProperties
		return

	"hasChanges"                : -> @grid.hasChanges()
	"getDataLength"             : -> @grid.data.getLength()
	"showRecordComponentsByCell": false
	"showRecordComponents"      : false
	"drawAheadRatio"            : 1.3
	"autoSaveEdits"             : true
	"autoDraw"                  : false
	"selectSingleRecord"        : (record) ->
		if @grid.getSelectionLength() is 0
			@grid.selectRecord record
		else
			@grid.selectSingleRecord record

		return
	"getFuncMenu"               : -> @funcMenu
	"canEdit"                   : false
	"filterOnKeypress"          : true
	"hasErrors"                 : -> @grid.hasErrors()
	"getFieldByName"            : (name) ->
		for field in @grid.fields
			if field.name is name then return field
		return undefined
	"showRollOver"              : true
	"autoFetchData"             : true
	"showRowNumbers"            : true
	"autoSaveConfig"            : true
	"getExpansionComponent"     : -> null
	"removeSelectedData"        : (callback, requestProperties) ->
		@grid.removeSelectedData callback, requestProperties
		return
	"showAdvancedFilter"        : false
	"restoreViewState"          : (callback) ->
		isc.OfflineSS.remove @grid.getIdentifier()
		@autoSaveConfig = false
		@fireCallback callback
		return
	"getCriteria"               : -> @grid.getCriteria()
	"setValueMap"               : (fieldID, map) ->
		@grid.setValueMap fieldID, map
		return
	"setDataSource"             : (dataSource) ->
		@grid.setDataSource dataSource
		return
	"setSelectedState"          : (selectedState) ->
		@grid.setSelectedState selectedState
		return
	"cancelEditing"             : ->
		@grid.cancelEditing()
		return
	"emptyMessage"              : "<h1>\u0414\u0430\u043D\u043D\u044B\u0445 \u043D\u0435\u0442.</h1>"
	"updateData"                : (updatedRecord, callback, requestProperties) ->
		@grid.updateData updatedRecord, callback, requestProperties
		return
	"setFuncMenu"               : (funcMenu) ->
		@funcMenu = funcMenu
		return
	"destroy"                   : ->
		@_save()
		@Super "destroy", arguments
		return
	"_save"                     : ->
		if @autoSaveConfig is true  then @saveViewState() ## Don't move
		return
	"wrapCells"                 : false
	"autoFetchTextMatchStyle"   : "substring"
	"getSelection"              : -> @grid.getSelection()
	"showResizeBar"             : false
	"focus"                     : ->
		@grid.focus()
		if @grid.getRecord(0)?
			@grid.selectRecord @grid.getRecord(0)
		return
	"fixedRecordHeights"        : false
	"dragTrackerMode"           : "icon"
	"setData"                   : (newData)->
		@grid.setData newData
		return
	"autoFitWidthApproach"      : "title"
	"startEditing"              : ->
		record = @grid.getRowNumSelectedGridRecord()
		@grid.startEditing record.rowNum, record.colNum
		return
	"addData"                   : (newRecord, callback, requestProperties) ->
		@grid.addData newRecord, callback, requestProperties
		return
	"modalEditing"              : true
	"selectionAppearance"       : "rowStyle"
	"selectRecords"             : (records, newState) ->
		@grid.selectRecords records, newState
		return
	"canSelectCells"            : false
	"setFields"                 : (fields) ->
		@grid.setFields fields
		return
	"selectRecord"              : (record, newState) ->
		@grid.selectRecord record, newState
		return
	"useClientFilteringSorting" : false
	"height"                    : "100%"
	"selectRecordByKey"         : (keyValue, newState) ->
		@grid.selectRecord @grid.findByKey(keyValue), newState
		return
	"fullRefresh"               : (criteria, callback, requestProperties) ->
		res = 0
		selected = @grid.getSelectedState()

		if isc.isA.Function(criteria) is true
			callback = criteria
			criteria = null

		criteria ?= if @grid.getCriteria()? then @grid.getCriteria() else {}
		criteria.ts = simpleSyS.timeStamp()

		###requestProperties ?= {}
		requestProperties.textMatchStyle = "substring"###

		@fetchData criteria,
		           (dsResponse, data, dsRequest) =>
			           res = if data? then data.length else 0

			           @grid.setSelectedState selected
			           if @grid.getSelectedRecords().length is 0
				           @selectFirstRecord()

			           if callback?
				           @fireCallback callback
				           return
		###, requestProperties###

		res

	"invalidateCache"                 : ->
		@grid.invalidateCache()
		return
	"saveViewState"                   : (callback) ->
		id = @grid.getIdentifier()
		data = @grid.getViewState()
		dataStr = isc.JSONSS.encode data,
		                            prettyPrint: false
		###console.log "Save component id: #{id} data: #{dataStr}"###
		isc.OfflineSS.put id, dataStr
		@fireCallback callback if callback?
		return
	"getViewState"                    : ->
		id = @grid.getIdentifier()
		dataStr = isc.OfflineSS.get @grid.getIdentifier()
		###console.log "Restore component id: #{id} data: #{dataStr}"###
		savedState = isc.JSONSS.decode dataStr
		@grid.setViewState savedState
	"width"                           : "100%"
	"cancelEditingConfirmationMessage": "Выход из режима редактирования повлечет к утере измененных(введенных) данных. Продолжить ?"
	"getAllRows"                      : -> @grid.data.getAllRows()
	"setContextMenu"                  : (menu)->
		if isc.isA.MenuSS(menu)
			@grid.contextMenu = menu.getMergedContextMenu()
		else if isc.isA.Menu(menu)
			@grid.contextMenu = (isc.MenuSS.create
				items: menu.items
				owner: @
			).getMergedContextMenu()

		return
	"getContextMenu"                  : ->
		@grid.contextMenu
	"setMasterGrid"                   : (grid, pkFieldNames) ->
		@grid.setMasterGrid grid, pkFieldNames
		return
	"refreshData"                     : (callback) ->
		@grid.refreshData callback
		return
	"initWidget"                      : ->
		#isc.debugTrac @getClassName(), @getIdentifier()
		@fields?.forEach (field) ->
			field.name = field.nameStrong.name if field.nameStrong?
			return

		@Super "initWidget", arguments

		@grid = isc.ListGrid.create
			"autoFetchData"                   : false,
			"canSelectText"                   : @canSelectText
			"dataFetchMode"                   : @dataFetchMode
			"identifier"                      : @identifier
			"autoFitFieldWidths"              : @autoFitFieldWidths
			"recordComponentPoolingMode"      : @recordComponentPoolingMode
			"showAllRecords"                  : @showAllRecords
			"rowContextClick"                 : @rowContextClick
			"groupStartOpen"                  : @groupStartOpen
			"getBaseStyle"                    : @getBaseStyle
			"dataProperties"                  : @dataProperties
			"clientOnly"                      : @clientOnly
			"showRecordComponentsByCell"      : @showRecordComponentsByCell
			"showRecordComponents"            : @showRecordComponents
			"drawAheadRatio"                  : @drawAheadRatio
			"detailField"                     : @detailField
			"autoSaveEdits"                   : @autoSaveEdits
			"autoDraw"                        : false
			"cellClick"                       : @cellClick
			"initialSort"                     : @initialSort
			"canEdit"                         : @canEdit
			"filterOnKeypress"                : @filterOnKeypress
			"selectionType"                   : @selectionType
			"showRollOver"                    : @showRollOver
			"showRowNumbers"                  : @showRowNumbers
			"canExpandRecords"                : @canExpandRecords
			"masterGrid"                      : @masterGrid
			"showSelectedStyle"               : @showSelectedStyle
			"data"                            : @data
			"owner"                           : @
			"emptyMessage"                    : @emptyMessage
			"wrapCells"                       : @wrapCells
			"autoFetchTextMatchStyle"         : @autoFetchTextMatchStyle
			"expansionMode"                   : @expansionMode
			"fields"                          : @fields
			"canDragSelectText"               : @canDragSelectText
			"dataSource"                      : @dataSource
			"fixedRecordHeights"              : @fixedRecordHeights
			"autoFitWidthApproach"            : @autoFitWidthApproach
			"modalEditing"                    : @modalEditing
			"selectionAppearance"             : @selectionAppearance
			"createRecordComponent"           : (record, colNum) => @createRecordComponent? record, colNum
			"updateRecordComponent"           : (record, colNum, component, recordChanged) => @updateRecordComponent? record, colNum, component, recordChanged
			"expansionDetailFieldProperties"  :
				"canSelectText": @canSelectTextExpandedField
			"canSelectCells"                  : @canSelectCells
			"alternateRecordStyles"           : @alternateRecordStyles
			"groupByField"                    : @groupByField
			"cancelEditingConfirmationMessage": @cancelEditingConfirmationMessage
			"focusChanged"                    : ->
				simpleSyS.setFuncMenu @funcMenu
				return
			"fetchDelay"                      : @fetchDelay
			"editByCell"                      : @editByCell
			"editEvent"                       : @editEvent
			"showFilterEditor"                : @showFilterEditor
			"dataPageSize"                    : @dataPageSize
			"cellChanged"                     : @cellChanged
			"getExpansionComponent"           : @getExpansionComponent
			"editComplete"                    : @editComplete
			"defaultFields"                   : @defaultFields
			"dragTrackerMode"                 : @dragTrackerMode
			"canHover"                        : @canHover
			"hoverWidth"                      : @hoverWidth
			"canResizeFields"                 : @canResizeFields
			"dragDataAction"                  : @dragDataAction
			"canReorderRecords"               : @canReorderRecords
			"canAcceptDroppedRecords"         : @canAcceptDroppedRecords
			"trackerImage"                    : @trackerImage
			"newRequestProperties"            : @newRequestProperties
			"editRequestProperties"           : @editRequestProperties
			"saveByCell"                      : @saveByCell
			"editingFields"                   : @editingFields
			"editWindowProperties"            : @editWindowProperties
			"canDragRecordsOut"               : @canDragRecordsOut
			"dateFormatter"                   : @dateFormatter
			"datetimeFormatter"               : @datetimeFormatter
			"selectFirstRecordAfterFetch"     : @selectFirstRecordAfterFetch
			"expandRecord"                    : @expandRecord
			"expandRecords"                   : @expandRecords

		@grid.rowClick = @rowClick if @rowClick? and isc.isA.Functtion @rowClick ## Убирать нельзя

		if isc.isA.Function @selectionChanged
			@setSelectionChanged @selectionChanged

		@grid.selectionChanged = (record, state) =>
			@grid.selectionChangedQueue?.forEach (func) -> if isc.isA.Function(func) is true then func(record, state);return
			return

		if isc.isA.Function @selectionUpdated
			@setSelectionUpdated @selectionUpdated

		@grid.selectionUpdated = (record, recordList) =>
			@grid.selectionUpdatedQueue?.forEach (func) -> if isc.isA.Function(func) is true then func(record, recordList);return
			return

		@initAdvancedFilter()

		if @masterGrid?
			@grid.setMasterGrid @masterGrid

		if @autoSaveConfig is true
			@getViewState()

		if @contextMenu
			if @saveItems and not isc.isA.Array(@saveItems)
				@saveItems = [@saveItems]

			if @autoSaveEdits and @saveItems
				@contextMenu.removeItems @saveItems

			@grid.contextMenu = (isc.MenuSS.create
				items: @contextMenu.items
				owner: @
			).getMergedContextMenu()
			@contextMenu = null
		else
			@grid.contextMenu = (isc.MenuSS.create
				owner: @
			).getMergedContextMenu()

		@grid.contextMenu.setOwner @

		if @dataSource? and @autoFetchData
			@filterBuilder?.setCriteria @initialCriteria
			@fetchData @initialCriteria

		if isc.isA.Function @canSelectRecord
			@grid.canSelectRecord = @canSelectRecord
		return
	"fetchDelay"                      : 500
	"startEditingNew"                 : (newValues, suppressFocus)->
		if @grid.masterGrid?
			@setForignFieldFields @grid, @grid.masterGrid

		if newValues?
			@grid.startEditingNew newValues, suppressFocus
		else
			@grid.startEditingNew @dataSource.wildRecordJS, suppressFocus
		return
	"editEvent"                       : "doubleClick"
	"getEditRecord"                   : -> @grid.getRecord @grid.getEditRow()
	"getSelectedRecord"               : -> @grid.getSelectedRecord()
	"getSelectedRecords"              : -> @grid.getSelectedRecords()
	"isSelected"                      : (record) -> @grid.isSelected record
	"canSelectTextExpandedField"      : true
	"discardAllEdits"                 : ->
		@grid.discardAllEdits()
		return
	"getSelectedState"                : -> @grid.getSelectedState()
	"getRecord"                       : (data) ->
		if isc.isA.Object(data) is true
			index = @grid.getRecordIndex(data)
			@grid.getRecord index
		else if isc.isA.Number(data) is true
			@grid.getRecord data
	"showFilterEditor"                : true
	"dataPageSize"                    : 75
	"getEditorType"                   : (field, values) ->
		@grid.Super "getEditorType", arguments
	"deselectRecord"                  : (record) ->
		@grid.deselectRecord record
		return
	"deselectRecords"                 : (records) ->
		@grid.deselectRecords records
		return
	"deselectAllRecords"              : ->
		@grid.deselectAllRecords()
		return
	"getFieldName"                    : (colNum)-> @grid.getFieldName colNum
	"getRowNum"                       : (record) ->
		@grid.getRowNum record
	"setSelectionAppearance"          : (selectionAppearance) ->
		@grid.setSelectionAppearance selectionAppearance
		return
	"setSelectionType"                : (selectionType) ->
		@grid.setSelectionType selectionType
		return



