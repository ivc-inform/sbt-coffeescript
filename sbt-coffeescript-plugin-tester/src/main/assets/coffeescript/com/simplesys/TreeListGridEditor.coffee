simpleSyS = @simpleSyS

isc.defineClass("TreeListGridEditor", isc.HLayoutSS).addProperties
	"getTreeSelectedRecord"               : -> @treeGrid.getSelectedRecord()
	"getListSelection"                    : -> @listGrid.getSelection()
	"findByKeyList"                       : (keyValue) -> @listGrid.findByKey(keyValue)
	"findByKeyTree"                       : (keyValue) -> @treeGrid.findByKey(keyValue)
	"discardListAllEdits"                 : ->
		@listGrid.discardAllEdits()
		return
	"discardTreeAllEdits"                 : ->
		@treeGrid.discardAllEdits()
		return
	"updateListData"                      : (updatedRecord, callback, requestProperties) ->
		@listGrid.updateData updatedRecord, callback, requestProperties
		return
	"updateTreeData"                      : (updatedRecord, callback, requestProperties) ->
		@treeGrid.updateData updatedRecord, callback, requestProperties
		return
	"removeListSelectedData"              : ->
		@listGrid.removeSelectedData()
		return
	"removeTreeSelectedData"              : ->
		@treeGrid.removeSelectedData()
		return
	"dataArrivedTree"                     : (startRecord, endRecord) -> undefined; return
	"dataArrivedList"                     : (startRecord, endRecord) -> undefined; return
	"widthTree"                           : "300"
	"widthList"                           : "*"
	"fetchData"                           : (criteria, callback, requestProperties) ->
		@treeGrid.fetchData criteria, callback, requestProperties
		return
	"fetchTreeData"                           : (criteria, callback, requestProperties) ->
		@treeGrid.fetchData criteria, callback, requestProperties
		return
	"fetchListData": (criteria, callback, requestProperties) ->
		@listGrid.fetchData criteria, callback, requestProperties
		return
	"fetchTreeDelay"                      : 500
	"fetchListDelay"                      : 500
	"showTreeRecordComponents"            : false
	"showListRecordComponents"            : false
	"selectListSingleRecordByKey"         : (keyValue, newStyle, callback) ->
		@listGrid.selectSingleRecordByKey keyValue, newStyle, callback
		return
	"selectTreeSingleRecordByKey"         : (keyValue, newStyle, callback) ->
		@treeGrid.selectSingleRecordByKey keyValue, newStyle, callback
		return
	"editByCellTree"                      : false
	"autoSaveListEdits"                   : true
	"autoSaveTreeEdits"                   : true
	"editByCellList"                      : false
	"getListSelectedRecord"               : -> @listGrid.getSelectedRecord()
	"enableChangeSelectionTree"           : true
	"showAllChild"                        : false
	"selectionTypeTree"                   : "single"
	"selectionTypeList"                   : "single"
	"getTreeSelection"                    : -> @treeGrid.getSelection()
	"autoDraw"                            : false
	"showTreeFilterEditor"                : true
	"cancelTreeEditing"                   : ->
		@treeGrid.cancelEditing()
		return
	"canAcceptDroppedRecordsTree"         : false
	"getFuncMenu"                         : -> @funcMenu
	"getTreeCriteria"                     : -> @treeGrid.getCriteria()
	"autoFetchData"                       : true
	"startListEditing"                    : ->
		@listGrid.startEditing()
		return
	"setTreeFields"                       : (fields) ->
		@treeGrid.setFields fields
		return
	"showTreeAdvancedFilter"              : false
	"startTreeEditingNew"                 : ->
		@treeGrid.startEditingNew()
		return
	"saveListAllEdits"                    : (rows, saveCallback)->
		@listGrid.saveAllEdits(rows, saveCallback)
		return
	"cancelEditingConfirmationMessageList": "Выход из режима редактирования повлечет к утере измененных(введенных) данных. Продолжить ?"
	"cancelEditingConfirmationMessageTree": "Выход из режима редактирования повлечет к утере измененных(введенных) данных. Продолжить ?"
	"showListAdvancedFilter"              : false
	"saveTreeAllEdits"                    : (rows, saveCallback) ->
		@treeGrid.saveAllEdits(rows, saveCallback)
		return
	"canAcceptDropTree"                   : false
	"drawAheadRatioList"                  : 1.3
	"setListSelectedState"                : (selectedState) ->
		@listGrid.setSelectedState selectedState
		return
	"getListSelectedState"                : -> @listGrid.getSelectedState()
	"drawAheadRatioTree"                  : 1.3
	"startListEditingNew"                 : (newValues, suppressFocus) ->
		###selection = @getTreeSelection()
		if selection.getLength() is 0
			isc.error "Сначала выбирите группу."
		else if selection.getLength() inst 1
			isc.error "Должна быть выбрана одна группа."
		else###
		@listGrid.startEditingNew newValues, suppressFocus
		return
	"setFuncMenu"                         : (funcMenu) ->
		@funcMenu = funcMenu
		return
	"showResizeBarList"                   : false
	"fullTreeRefresh"                     : ->
		@treeGrid.fullRefresh()
		return
	"getListEditRecord"                   : -> @listGrid.getRecord @listGrid.getEditRow()
	"heightTree"                          : "100%"
	"heightList"                          : "100%"
	"setTreeSelectedState"                : (selectedState) ->
		@treeGrid.setSelectedState selectedState
		return
	"getTreeSelectedState"                : -> @treeGrid.getSelectedState()
	"canSelectCellsList"                  : false
	"showTreeRecordComponentsByCell"      : false
	"canSelectCellsTree"                  : false
	"emptyMessageTree"                    : "<h1>Данных нет.</h1>"
	"showResizeBarTree"                   : true
	"emptyMessageList"                    : "<h1>Данных нет.</h1>"
	"showListFilterEditor"                : true
	"setTreeDataSource"                   : (dataSource) ->
		@treeGrid.setDataSource dataSource
		return
	"canReparentNodesTree"                : true
	"filterTreeOnKeypress"                : true
	"cancelListEditing"                   : ->
		@listGrid.cancelEditing()
		return
	"dataPageSizeTree"                    : 75
	"dataPageSizeList"                    : 75
	"setListDataSource"                   : (dataSource) ->
		@listGrid.setDataSource dataSource
		return
	"showOpenIconsTree"                   : true
	"height"                              : "100%"
	"autoFetchTextMatchStyleTree"         : "substring"
	"loadDataOnDemandTree"                : false
	"autoFetchTextMatchStyleList"         : "substring"
	"startTreeEditing"                    : ->
		@treeGrid.startEditing treeGrid.getRowNumSelectedGridRecord()
		return
	"width"                               : "100%"
	"canEditTree"                         : true
	"canEditList"                         : true
	"setContextMenuTreeGridEditor"        : (menu) ->
		@contextMenuTreeGridEditor = menu.setOwner @treeGrid
		@treeGrid.setContextMenu menu
		@contextMenuTreeGridEditor

	"setContextMenuListGridEditor"        : (menu) ->
		@contextMenuListGridEditor = menu.setOwner @listGrid
		@listGrid.setContextMenu menu
		@contextMenuListGridEditor

	"closedIconSuffix" : ""
	"dataFetchModeList" : "paged"
	"dataFetchModeTree" : "basic"
	"canDragRecordsOutList" : false
	"canDragRecordsOutTree" : false
	"refreshDataList": (callback) ->
		@listGrid.refreshData callback
		return
	"refreshDataTree": (callback) ->
		@treeGrid.refreshData callback
		return
	"refreshRecordComponentTree":  (rowNum, colNum) ->
		@treeGrid.refreshRecordComponent recordDate, colNum
		return
	"refreshRecordComponentList":  (rowNum, colNum) ->
		@listGrid.refreshRecordComponent recordDate, colNum
		return

	"initWidget"                          : ->
		#isc.debugTrac @getClassName(), @getIdentifier()
		@Super "initWidget", arguments

		@treeGrid = isc.TreeGridEditor.create
		    #"data"                            : if not @dataTree? then undefined else @dataTree
			"showRecordComponentsByCell"      : @showTreeRecordComponentsByCell
			"folderDrop"                      : @folderDropTree
			"loadDataOnDemand"                : @loadDataOnDemandTree
			"showRecordComponents"            : @showTreeRecordComponents
			"drawAheadRatio"                  : @drawAheadRatioTree
			"autoDraw"                        : false
			"initialSort"                     : @initialSortTree
			"canEdit"                         : @canEditTree
			"selectionType"                   : @selectionTypeTree
			"autoFetchData"                   : @autoFetchData
			"folderIcon"                      : @folderIconTree
			"showAdvancedFilter"              : @showTreeAdvancedFilter
			"contextMenu"                     : @contextMenuTreeGridEditor
			"identifier"                      : "#{@getIdentifier()}_treeGrid"
			"owner"                           : @
			"emptyMessage"                    : @emptyMessageTree
			"wrapCells"                       : @wrapTreeCells
			"canAcceptDroppedRecords"         : @canAcceptDroppedRecordsTree
			"fields"                          : @fieldsTree
			"defaultFields"                    : @defaultFieldsTree
			"showResizeBar"                   : true
			"dataSource"                      : @dataSourceTree
			"canReparentNodes"                : @canReparentNodesTree
			"canSelectCells"                  : @canSelectCellsTree
			"folderDropImage"                 : @folderDropImageTree
			"height"                          : @heightTree
			"nodeIcon"                        : @nodeIconTree
			"width"                           : "30%"
			"cancelEditingConfirmationMessage": @cancelEditingConfirmationMessageTree
			"editByCell"                      : @editByCellTree
			"showOpenIcons"                   : @showOpenIconsTree
			"showFilterEditor"                : @showTreeFilterEditor
			"dataPageSize"                    : @dataPageSizeTree
			"closedIconSuffix"                : @closedIconSuffix
			"newRequestProperties"            : @newTreeRequestProperties
			"editRequestProperties"           : @editTreeRequestProperties
			"editingFields"                   : @editingTreeFields
			"autoSaveEdits"                   : @autoSaveTreeEdits
			"saveByCell"                      : @saveByTreeCell
			"dataFetchMode"                   : @dataFetchModeTree
			"editWindowProperties"            : @editWindowPropertiesTree
			"canDragSelectText"               : @canDragSelectText
			"canDragRecordsOut"               : @canDragRecordsOutTree
			"trackerImage"                    : @trackerImageTree
			"selectionAppearance"             : @selectionAppearanceTree
			"selectFirstRecordAfterFetch"     : @selectFirstRecordAfterFetchTree
			"createRecordComponent"           : @createTreeRecordComponent
			"updateRecordComponent"           : @updateTreeRecordComponent
			"recordComponentPoolingMode"      : @recordTreeComponentPoolingMode
			"dataArrived"                     : @dataArrivedTree
			"resized"                         : ->
				isc.OfflineSS.putNumber "#{@getIdentifier()}.width", @getWidth() if @isDrawn() is true
				return

		@treeGrid.setWidth isc.OfflineSS.getNumber "#{@treeGrid.getIdentifier()}.width", @treeGrid.getWidth()

		###simpleSyS._initMenus @treeGrid
		simpleSyS._RecordComponent @treeGrid, "create"
		simpleSyS._RecordComponent @treeGrid, "update"###

		@listGrid = isc.ListGridEditor.create
			"showRecordComponentsByCell"      : @showListRecordComponentsByCell
			"showRecordComponents"            : @showListRecordComponents
			"autoDraw"                        : false
			"drawAheadRatio"                  : @drawAheadRatioList
			"initialSort"                     : @initialSortList
			"canEdit"                         : @canEditList
			"filterOnKeypress"                : @filterListOnKeypress
			"selectionType"                   : @selectionTypeList
			"autoFetchData"                   : @autoFetchData
			"masterGrid"                      : @treeGrid
			"showAdvancedFilter"              : @showListAdvancedFilter
			"contextMenu"                     : @contextMenuListGridEditor
			"identifier"                      : "#{@getIdentifier()}_listGrid"
			"owner"                           : @
			"emptyMessage"                    : @emptyMessageList
			"wrapCells"                       : @wrapListCells
			"autoFetchTextMatchStyle"         : @autoFetchTextMatchStyleList
			"fields"                          : @fieldsList
			"defaultFields"                    : @defaultFieldsList
			"showResizeBar"                   : false
		##"targetResizeBar"                   : "next"
			"dataSource"                      : @dataSourceList
			"createRecordComponent"           : @createListRecordComponent
			"updateRecordComponent"           : @updateListRecordComponent
			"canSelectCells"                  : @canSelectCellsList
			"height"                          : @heightList
			"cancelEditingConfirmationMessage": @cancelEditingConfirmationMessageList
			"width"                           : "*"
			"fetchDelay"                      : @fetchListDelay
			"editByCell"                      : @editByCellList
			"dataPageSize"                    : @dataPageSizeList
			"showFilterEditor"                : @showListFilterEditor
			"newRequestProperties"            : @newListRequestProperties
			"editRequestProperties"           : @editListRequestProperties
			"editingFields"                   : @editingListFields
			"autoSaveEdits"                   : @autoSaveListEdits
			"saveByCell"                      : @saveByListCell
			"dataFetchMode"                   : @dataFetchModeList
			"editWindowProperties"            : @editWindowPropertiesList
			"canDragSelectText"               : @canDragSelectText
			"canDragRecordsOut"               : @canDragRecordsOutList
			"trackerImage"                    : @trackerImageList
			"selectionAppearance"             : @selectionAppearanceList
			"selectFirstRecordAfterFetch"     : @selectFirstRecordAfterFetchList
			"recordComponentPoolingMode"      : @recordListComponentPoolingMode
			"dataArrived"                     : @dataArrivedList

		###simpleSyS._initMenus @listGrid
		simpleSyS._RecordComponent @listGrid, "create"
		simpleSyS._RecordComponent @listGrid, "update"###

		###@treeGrid.grid.contextMenu.log()
		@listGrid.grid.contextMenu.log()###

		@addMember ch = isc.ChainMasterDetail.create
			members: [
				@treeGrid
				@listGrid
			]

		ch.getViewState()

		if @dataSourceTree? and @dataSourceList? and @autoFetchData is true
			@fetchData @getTreeCriteria(),
				           (dsResponse, data, dsRequest) =>
					           @treeGrid.selectFirstRecord()
					           return
			return
	"fullListRefresh"                     : ->
		@listGrid.fullRefresh()
		return
	"filterListOnKeypress"                : true
	"setListFields"                       : (fields) ->
		@listGrid.setFields fields
		return
	"showListRecordComponentsByCell"      : false
	"setTreeCanReparentNodes"             : (value) ->
		@treeGrid.canReparentNodes = value
		return
	"getListCriteria": -> @listGrid.getCriteria()
	"getListGrid": -> @listGrid
	"getTreeGrid": -> @treeGrid
	"getViewState": ->
		@listGrid.getViewState()
		@treeGrid.getViewState()
		return


