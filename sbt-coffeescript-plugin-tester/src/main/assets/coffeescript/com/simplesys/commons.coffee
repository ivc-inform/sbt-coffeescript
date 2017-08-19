top = @

if ! top.simpleSyS? then top.simpleSyS = {}
if ! top.isc? then top.isc = {}

simpleSyS = top.simpleSyS
isc = top.isc

simpleSyS._getGrid = (that) ->
	if isc.isA.ListGrid(that.grid) is true then that.grid
	else if isc.isA.ListGrid(that) is true then that

simpleSyS._createRecordComponent = (that) =>
	grid = simpleSyS._getGrid that

	if grid?.showRecordComponents is true and grid?.showRecordComponentsByCell is true
		grid.createRecordComponent = (record, colNum) ->
			fieldName = grid.getFieldName colNum
			foreignFields = grid.dataSource.getForeignFields()
			result = null

			for foreignField in foreignFields
				lookupFields = grid.dataSource.getLookupFileds(foreignField.name).map (field) ->
					field_name : field.name
					field_captionClassLookup : field.captionClassLookup

				if lookupFields?
					_lookupFields = lookupFields.map (item) -> item.field_name
					if _lookupFields.contains(fieldName)
						result = isc.LookupEditor.create
							editorIdentifier: that.getIdentifier() + fieldName
							record          : record
							owner           : top
							foreignField    : foreignField
							lookupFields    : lookupFields

						break

			result
		return

simpleSyS._updateRecordComponent = (that) =>
	grid = simpleSyS._getGrid that

	if grid?.showRecordComponents is true and grid?.showRecordComponentsByCell is true
		grid.updateRecordComponent = (record, colNum, component, recordChanged) ->
			component.record = record
			return
		return

simpleSyS._initMenus = (that) ->
	that.Super "initWidget", arguments

	##that.grid.canReparentNodes = false ##Не убирать, необходима для TreeGridEditor

	##that.funcMenu?.items.forEach (item) -> item.owner = that; return

	##that.contextMenu?.items.forEach (item) -> item.owner = that; return
	##console.warn "simpleSyS._initMenus() is deprecated"
	return

simpleSyS._RecordComponent = (that, mode) ->
	funcName = "simpleSyS._#{mode}RecordComponent"
	if top.isFunction(funcName) is true
		try
			that.evaluate "#{funcName}(that)", "that": that
		catch e
			that.logError e
		return

simpleSyS._enableDeleteFromTree = (that) ->
	owner = that.owner
	if simpleSyS.checkOwner(owner)?
		records = owner.getSelectedRecords()
		res = owner.getSelectedRecords().length > 0
		dataSource = owner.dataSource
		pkFields = dataSource.getPrimaryKeyFieldNames()
		tree = owner.grid.data

		for record in records
			pk = pkFields.map (field) -> record[field]

			node = tree.findById pk
			if tree.isFolder(node)
				res = false
				break
	res

simpleSyS._openFolders = (that) ->
	owner = that.owner
	if simpleSyS.checkOwner(owner)?
		records = owner.getSelectedRecords()
		dataSource = owner.dataSource
		pkFields = dataSource.getPrimaryKeyFieldNames()
		tree = owner.grid.data
		nodes = []

		_openFolders1 = (nodes) ->
			nodes.forEach (node) ->
				nodes1 = tree.getChildren node
				if nodes1?
					_openFolders1(nodes1)
				tree.openFolder node
				return
			return

		if records.length > 0
			for record in records
				pk = pkFields.map (field) -> record[field]

				node = tree.findById(pk)
				if tree.isFolder(node) is true
					nodes.add node

			_openFolders1 nodes
	return


simpleSyS.getGuid = -> isc.say simpleSyS.guid(); return

simpleSyS.underConstruction = -> isc.info "Sorry, this under consruction."; return

simpleSyS.notImplementation = -> isc.info "Sorry, implementation not found."; return

isc.debugTrap = (obj...) ->
	if obj? and obj.length > 0
		obj[0]
	else
		[]

isc.debugTrac = (obj...) ->
	json = isc.JSON.encode(obj, prettyPrint: true)
	console.log "obj: #{json}"
	return

isc.deletePrivateProps = (obj) ->
	for prop  of obj
		if prop.charAt(0) is "_"
			delete obj[prop]
	obj


isc.getPropValue = (object, name) ->
	try
		object[name]
	catch
		undefined

isc.setPropValue = (object, name, value) ->
	try
		object[name] = value
		value
	catch
		undefined

isc.deleteProp = (object, propName) ->
	try
		delete object[propName]
	catch
		undefined
	return

isc.getWindowObject = (name) ->
	try
		window[name]
	catch
		undefined

isc.js_beautify = if js_beautify? then js_beautify else (str) -> str

isc.setArrayItem = (array, index, value) ->
	if isc.isA.Array(array)
		array[index] = value
		return
		
isc.createClass = (className, args) ->
	creater = isc[className].create
	creater(args)

