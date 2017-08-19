isc.defineClass("TreeGridEditor", isc.VLayoutSS, isc.GridEditorInterface).addProperties
	"hoverWidth": 300
	"canDragSelectText": true
	"showOpenIcons": true,
	"autoFitFieldWidths": false
	"canAutoFitWidth": false
	"findByKey": (keyValue) -> @grid.findByKey keyValue
	"removeData": (removeRecord, callback, requestProperties) ->
		@grid.removeData removeRecord, callback, requestProperties
		return
	"saveAllEdits": (rows, saveCallback) ->
		@grid.saveAllEdits(rows, saveCallback)
		return
	"recordComponentPoolingMode": "viewport"
	"dragTrackerMode": "icon"
	"showAllRecords": false
	"canAcceptDroppedRecords": false
	"selectFirstRecordAfterFetch": true
	"applyRecordData" : (recordDate) ->
		@grid.applyRecordData recordDate
		return
	"invalidateRecordComponents" : () ->
		@grid.invalidateRecordComponents()
		return
	"refreshRecordComponent"     : (rowNum, colNum) ->
		@grid.refreshRecordComponent recordDate, colNum
		return
	"setEditValue": (rowNum, colNum, value) ->
		@grid.refreshRecordComponent rowNum, colNum, value
		return
	"getEditFormItem" : (field) ->
		@grid.getEditFormItem field
	"fetchData": (criteria, callback, requestProperties) ->
		if @useClientFilteringSorting is false
			_callback = (dsResponse, data, dsRequest) =>
				@grid.selectFirstRecord() if @selectFirstRecordAfterFetch
				@fireCallback callback
				return

			@grid.filterData criteria, _callback, requestProperties
			@filterBuilder?.setCriteria criteria
		else
			_callback = (dsResponse, data, dsRequest) =>
				resultSet = isc.ResultSet.create
					dataSource: @dataSource
					allRows: data

				@grid.setData resultSet
				@fireCallback callback
				return

			@dataSource.filterData criteria, _callback, requestProperties
		return
	"hasChanges": -> @grid.hasChanges()
	"getDataLength": -> @grid.data.getLength()
	"getData": -> @grid.getData()
	"showRecordComponentsByCell": false
	"loadDataOnDemand": false
	"showRecordComponents": false
	"showAllChild": false
	"openedAll": false,
	"drawAheadRatio": 1.3
	"autoSaveEdits": true
	"autoDraw": false
	"selectByIds": (ids) ->
		if not ids?
			return undefined
		if isc.isA.Array(ids) is false
			ids = [ids]
		data = @getData()
		if data?
			ids.forEach (id) -> @grid.selectRecord(data.findById(id))
		return
	"setSelectedRecordsAsFolders": ->
		@setRecordsAsFolders @getSelectedRecords()
	"setRecordsAsFolders": (records) ->
		nodes = @selectByIds records
		nodes
	"cascadeSelection": false
	"getFuncMenu": -> @funcMenu
	"canEdit": false
	"selectFirstRecord": ->
		@grid.selectFirstRecord()
	"filterOnKeypress": true
	"hasErrors": -> @grid.hasErrors()
	"getFieldByName": (name) ->
		for field in  @grid.fields
			if field.name is name then return field
		return undefined
	"showRollOver": true
	"selectionType": "single"
	"autoFetchData": true
	"showRowNumbers": true
	"autoSaveConfig": true
	"selectSingleRecord": (record) ->
		if @grid.getSelectionLength() is 0
			@grid.selectRecord record
		else
			@grid.selectSingleRecord record
		return
	"removeSelectedData": (callback, requestProperties) ->
		parents = @grid.getSelectedRecords().map (record) =>
			@grid.data.getParent record

		@grid.removeSelectedData (dsResponse, data, dsRequest) =>
			                         parents.forEach ((node) =>
				                         node.isFolder = @grid.data.hasChildren node;
				                         return)
			                         @.fireCallback callback;
			                         return
		                         , requestProperties
		return
	"showAdvancedFilter": false
	"showSelectedStyle": true
	"restoreViewState": (callback) ->
		isc.OfflineSS.remove @grid.getIdentifier()
		@autoSaveConfig = false
		@fireCallback callback
		return
	"getCriteria": -> @grid.getCriteria()
	"setValueMap": (fieldID, map)->
		@grid.setValueMap fieldID, map
		return
	"selectSingleRecordByKey": (keyValue, newState, callback) ->
		node = @grid.data.findById keyValue
		if node?
			parents = @grid.data.getParents node
			parents.forEach (parent) => @grid.data.openFolder parent; return
			@grid.selectRecord node, newState
			isc.Class.fireCallback callback
		else
			null
		
	"setDataSource": (dataSource) ->
		@grid.setDataSource dataSource
		return
	"setSelectedState": (selectedState) ->
		@grid.setSelectedState selectedState
		return
	"cancelEditing": ->
		@grid.cancelEditing()
		return
	"emptyMessage": "<h1>\u0414\u0430\u043D\u043D\u044B\u0445 \u043D\u0435\u0442.</h1>"
	"updateData": (updatedRecord, callback, requestProperties) ->
		@grid.updateData updatedRecord, callback, requestProperties
		return
	"setFuncMenu": (funcMenu) ->
		@funcMenu = funcMenu
		return
	"destroy": ->
		@_save() ## Don't move
		@Super "destroy", arguments
		return
	"_save": ->
		if @autoSaveConfig is true then @saveViewState() ## Don't move
		return
	"wrapCells": false
	"autoFetchTextMatchStyle": "substring"
	"getSelection": -> @grid.getSelection()
	"showResizeBar": false
	"focus": ->
		@grid.focus()
		if @grid.getRecord(0)?
			@grid.selectRecord @grid.getRecord(0)
		return
	"fixedRecordHeights": false
	"setData": (newData) ->
		@grid.setData newData
		return
	"autoFitWidthApproach": "title"
	"startEditing": (newLine) ->
		record = @grid.getRowNumSelectedGridRecord()

		if newLine is true
			try
				@grid.startEditing record.rowNum + 1, record.colNum
			catch e
##console.error e.stack.toString()
				@grid.startEditing record.rowNum, record.colNum
		else
			@grid.startEditing record.rowNum, record.colNum
		return
	"canReparentNodes": false
	"addData": (newRecord, callback, requestProperties) ->
		@grid.addData newRecord, callback, requestProperties
		return
	"modalEditing": true
	"selectionAppearance": "rowStyle"
	"openAll": ->
		@grid.filterData @grid.getCriteria(),
		                 ->
			                 @grid.getData().openAll()
			                 return
		return
	"selectRecords": (records, newState) ->
		@grid.selectRecords records, newState
		return
	"canSelectCells": false
	"setFields": (fields) ->
		@grid.setFields fields
		return
	"selectRecord": (record, newState) ->
		@grid.selectRecord record, newState
		return
	"useClientFilteringSorting": false
	"height": "100%"
	"selectRecordByKey": (keyValue, newState) ->
		@grid.selectRecord @grid.findByKey(keyValue), newState
		return
	"fullRefresh": (initialCriteria) ->
		selectedState = @grid.getSelectedState()
		criteria = isc.addProperties (if @grid.getCriteria()? then @grid.getCriteria() else {}), initialCriteria
		criteria.ts = simpleSyS.timeStamp()
		@fetchData criteria
		return
	"invalidateCache": ->
		@grid.invalidateCache()
		return
	"saveViewState": (callback) ->
		id = @grid.getIdentifier()
		data = @grid.getViewState()
		dataStr = isc.JSONSS.encode data,
		                            prettyPrint: false
		###console.log "Save component id: #{id} data: #{dataStr}"###
		isc.OfflineSS.put id, dataStr
		@fireCallback callback if callback?
		return
	"getViewState": ->
		id = @grid.getIdentifier()
		dataStr = isc.OfflineSS.get @grid.getIdentifier()
		###console.log "Restore component id: #{id} data: #{dataStr}"###
		savedState = isc.JSONSS.decode dataStr
		@grid.setViewState savedState
		return
	"width": "100%"
	"cancelEditingConfirmationMessage": "Выход из режима редактирования повлечет к утере измененных(введенных) данных. Продолжить ?"
	"getAllRows": -> @grid.data.getAllRows()
	"setContextMenu": (menu)->
		if isc.isA.MenuSS(menu)
			@grid.contextMenu = menu.getMergedContextMenu()
		else if isc.isA.Menu(menu)
			@grid.contextMenu = (isc.MenuSS.create
				items: menu.items
				owner: @
			).getMergedContextMenu()
		return
	"dropIconSuffix": "drop"
	"openIconSuffix": "open"
	"closedIconSuffix": "closed"
	"getContextMenu": ->
		@grid.contextMenu
	"getExpansionComponent": -> null
	"getFieldName": (colNum)-> @grid.getFieldName colNum
	"refreshData": (callback) ->
		@grid.refreshData callback
		return
	"initWidget": ->
		#isc.debugTrac @getClassName(), @getIdentifier()
		@fields?.forEach (field) ->
			field.name = field.nameStrong.name if field.nameStrong?
			return

		@Super "initWidget", arguments
		
		@grid = isc.TreeGrid.create
			"autoFetchData"                   : false,
			"dataFetchMode"                   : @dataFetchMode
			"identifier"                      : @identifier
			"autoFitFieldWidths"              : @autoFitFieldWidths
			"dropIconSuffix"                  : @dropIconSuffix
			"recordComponentPoolingMode"      : @recordComponentPoolingMode
			"showAllRecords"                  : @showAllRecords
			"rowContextClick"                 : @rowContextClick
			"dataProperties"                  : @dataProperties
			"getBaseStyle"                    : @getBaseStyle
			"clientOnly"                      : @clientOnly
			"showRecordComponentsByCell"      : @showRecordComponentsByCell
			"loadDataOnDemand"                : @loadDataOnDemand
			"showRecordComponents"            : @showRecordComponents
			"drawAheadRatio"                  : @drawAheadRatio
			"cellClick"                       : @cellClick
			"detailField"                     : @detailField
			"autoSaveEdits"                   : @autoSaveEdits
			"canAcceptDroppedRecords"         : @canAcceptDroppedRecords
			"autoDraw"                        : false
			"initialSort"                     : @initialSort
			"showOpenIcons"                   : @showOpenIcons
			"cascadeSelection"                : @cascadeSelection
			"canEdit"                         : @canEdit
			"filterOnKeypress"                : @filterOnKeypress
			"selectionType"                   : @selectionType
			"showRollOver"                    : @showRollOver
			"folderIcon"                      : @folderIcon
			"showRowNumbers"                  : @showRowNumbers
##"masterGrid"                      : @masterGrid
			"canExpandRecords"                : @canExpandRecords
			"showSelectedStyle"               : @showSelectedStyle
			"data"                            : @data
			"owner"                           : @
			"emptyMessage"                    : @emptyMessage
			"wrapCells"                       : @wrapCells
			"openIconSuffix"                  : @openIconSuffix
			"autoFetchTextMatchStyle"         : @autoFetchTextMatchStyle
			"expansionMode"                   : @expansionMode
			"fields"                          : @fields
			"canDragSelectText"               : @canDragSelectText
			"dataSource"                      : @dataSource
			"fixedRecordHeights"              : @fixedRecordHeights
			"autoFitWidthApproach"            : @autoFitWidthApproach
			"canReparentNodes"                : @canReparentNodes
			"modalEditing"                    : @modalEditing
			"selectionAppearance"             : @selectionAppearance
			"createRecordComponent"           : @createRecordComponent
			"updateRecordComponent"           : @updateRecordComponent
			"canSelectText"                   : @canSelectText
			"expansionDetailFieldProperties"  :
				"canSelectText": @canSelectTextExpandedField
			"canSelectCells"                  : @canSelectCells
##"height"                          : "*"
			"nodeIcon"                        : @nodeIcon
			"alternateRecordStyles"           : @alternateRecordStyles
			"closedIconSuffix"                : @closedIconSuffix
##"width"                           : "100%"
			"cancelEditingConfirmationMessage": @cancelEditingConfirmationMessage
			"focusChanged"                    : ->
				simpleSyS.setFuncMenu @funcMenu
				return
			"fetchDelay"                      : @fetchDelay
			"editByCell"                      : @editByCell
			"editEvent"                       : @editEvent
			"showDropIcons"                   : @showDropIcons
			"showPartialSelection"            : @showPartialSelection
			"showFilterEditor"                : @showFilterEditor
			"dataPageSize"                    : @dataPageSize
			"cellChanged"                     : @cellChanged
			"getExpansionComponent"           : @getExpansionComponent
			"editComplete"                    : @editComplete
			"defaultFields"                   : @defaultFields
			"dragTrackerMode"                 : @dragTrackerMode
			"canHover"                        : @canHover
			"hoverWidth"                      : @hoverWidth
			"dragDataAction"                  : @dragDataAction
			"canDragRecordsOut"               : @canDragRecordsOut
			"canReorderRecords"               : @canReorderRecords
			"trackerImage"                    : @trackerImage
			"newRequestProperties"            : @newRequestProperties
			"editRequestProperties"           : @editRequestProperties
			"editingFields"                   : @editingFields
			"saveByCell"                      : @saveByCell
			"editWindowProperties"            : @editWindowProperties
			"canDragRecordsOut"               : @canDragRecordsOut
			"dateFormatter"                   : @dateFormatter
			"datetimeFormatter"               : @datetimeFormatter
			"selectFirstRecordAfterFetch"     : @selectFirstRecordAfterFetch

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
		###@grid.contextMenu.log()###

		@grid.setMasterGrid @masterGrid if @masterGrid?
		if @dataSource? and @autoFetchData
			@filterBuilder?.setCriteria @initialCriteria
			@fetchData @initialCriteria, =>
				@selectFirstRecord()
				return

		@grid.canReparentNodes = false ##Не убирать

		if isc.isA.Function @canSelectRecord
			@grid.canSelectRecord = @canSelectRecord
		return

	"fetchDelay": 500

	"setMasterGrid": (grid, pkFieldNames) ->
		@grid.setMasterGrid grid, pkFieldNames
		return

	"localEditingNew": true

	"startEditingNew": (newValues, suppressFocus)->
		if newValues?
			@grid.startEditingNew newValues, suppressFocus
		else
			record = @getSelectedRecord()

			if record?
				@setForignFieldFields @grid

				if @grid.masterGrid?
					@setForignFieldFields @grid, @grid.masterGrid

			@dataSource.wildRecordJS = undefined if @grid.getSelectedRecords().length is 0

			@dataSource.addData @dataSource.wildRecordJS,
			                    (dsResponse, data, dsRequest) =>
				                    id = data[0][_this.grid.data.idField]
				                    _node = @grid.data.findById id
				                    parent = @grid.data.getParent _node
				                    @grid.data.openFolder parent, (node) =>
					                    @grid.selectSingleRecord _node
					                    @startEditing()
					                    return
				                    return
		return

	"editEvent": "doubleClick"
	"getEditRecord": -> @grid.getRecord @grid.getEditRow()
	"showDropIcons": true
	"getSelectedRecord": -> @grid.getSelectedRecord()
	"getSelectedRecords": -> @grid.getSelectedRecords()
	"isSelected": (record) -> @grid.isSelected record
	"canSelectTextExpandedField": true
	"discardAllEdits": ->
		@grid.discardAllEdits()
		return
	"getRecord": (data) ->
		if isc.isA.Object(data) is true
			index = @grid.getRecordIndex(data)
			@grid.getRecord index
		else if isc.isA.Number(data) is true
			@grid.getRecord data
	"getSelectedState": -> @grid.getSelectedState()
	"showPartialSelection": false
	"showFilterEditor": true
	"dataPageSize": 75
	"getEditorType": (field, values) ->
		@grid.Super "getEditorType", arguments
	"deselectRecord": (record) ->
		@grid.deselectRecord record
		return
	"deselectRecords": (records) ->
		@grid.deselectRecords records
		return
	"deselectAllRecords": ->
		@grid.deselectAllRecords()
		return
	"getFieldName": (colNum)-> @grid.getFieldName colNum
	"getRowNum": (record) ->
		@grid.getRowNum record
	"setSelectionAppearance": (selectionAppearance) ->
		@grid.setSelectionAppearance selectionAppearance
		return
	"setSelectionType": (selectionType) ->
		@grid.setSelectionType selectionType
		return
