simpleSyS = @simpleSyS

isc.defineClass("MenuSS", isc.Menu).addProperties
	"shadowDepth": 10
	"autoDraw": false
	"showShadow": true
	"setOwner": (owner) ->
		@owner = owner
		if owner? and @items?
			(@items = @items.map (item) -> item.owner = owner; item)
		@

	"setTabSet" : (tabSet) ->
		@tabSet = tabSet
		if tabsSet? and @items?
			(@items = @items.map (item) -> if item.owner? then item.owner.tabsSet = tabsSet; item)
		@

	"log": ->
		console.log "Component: #{@getIdentifier()}"
		for item in @items
			console.log "item: #{item.title}, owner: #{item.owner.getIdentifier()}"
		return

	"setItems": (items) ->
		@Super "setItems", arguments
		@

	"getMergedContextMenu": ->
		itemsSystemContextMenu = [
			{
				"isSeparator": true
				"identifier": "ControlSystemMenuSeparator1"
			}
		]

		itemsSystemContextMenu2 = [
			{
				"title": "\u0421\u043E\u0445\u0440\u0430\u043D\u0438\u0442\u044C \u043A\u043E\u043D\u0444\u0438\u0433\u0443\u0440\u0430\u0446\u0438\u044E",
				"click": =>
					if @owner?
						###console.log "item: #{@title}, owner: #{@owner.getIdentifier()}"###
						@owner.saveViewState? ->
							isc.ok "Сохранение выполнено."
							return
					else
						simpleSyS.safeException "Not enabled owner pointer"
					return
				"icon": "settings-icon.png"
				"identifier": "ControlSystemMenu.SaveViewState"
			}
			{
				"title": "\u0412\u043E\u0441\u0441\u0442\u0430\u043D\u043E\u0432\u0438\u0442\u044C \u043A\u043E\u043D\u0444\u0438\u0433\u0443\u0440\u0430\u0446\u0438\u044E '\u043F\u043E-\u0443\u043C\u043E\u043B\u0447\u0430\u043D\u0438\u044E'"
				"click": =>
					if @owner?
						@owner.restoreViewState? =>
							@owner.autoSaveConfig = false if @owner.autoSaveConfig?
							isc.ok "Восстановление выполнено. Необходима перезагрузка формы."
							return
					else
						simpleSyS.safeException "Not enabled owner pointer"
					return
				"icon": "restore.png",
				"identifier": "ControlSystemMenu.RestoreViewState"
			}
		]

		if @items?
			_items = itemsSystemContextMenu.map (item) -> item.identifier
			_items = @items.filter (item) -> not _items.contains item.identifier
			_items.addList itemsSystemContextMenu
			_items.addList itemsSystemContextMenu2
		else
			_items = itemsSystemContextMenu2
		@setItems _items

	"addItem": (item, pos) ->
		_item = @filter4Visiblity(item)
		if isc.isA.Array(_item) and _item.length > 0
			_item = _item[0]

		@data = [] unless isc.isA.Array(@data)
		q_exstty = @data.filter (_item) -> _item.identifier? and item.identifier? and  _item.identifier is item.identifier

		if isc.isA.Array(q_exstty) and q_exstty.length is 0
			if isc.isA.Number(pos)
				@data.addAt _item, pos
			else
				@data.add _item
		return

	"addItems": (itemArray, pos) ->
		if not isc.isA.Array(itemArray)
			itemArray = [itemArray]

		for item in itemArray
			@addItem item, pos
			if isc.isA.Number pos
				pos++
		return

	"addItemProperties": (identifier, properties) ->
		@items.forEach (item) ->
			if item.identifier is identifier
				isc.addProperties item, properties
				return
		return

	"removeItem": (item) ->
		if isc.isA.Number(item) is true
			@data.removeAt item
		else if isc.isA.Object(item) is true
			@data.forEach (_item) => if _item.identifier? and item.identifier? and _item.identifier is item.identifier then @data.remove(_item); return
		else if isc.isA.String(item) is true
			@data.forEach (_item) => if _item.identifier? and _item.identifier is item then @data.remove(_item); return
		return

	"removeItems": (items) ->
		if not isc.isA.Array(items)
			items = [items]
		items.forEach (item) => @removeItem(item)
		return

	"replaceItems": (oldItems, newItems) ->
		@removeItems oldItems
		@addItems newItems
		return

	"setDynamicItems": ->
		@items = @filter4Visiblity @items
		@Super "setDynamicItems", arguments
		return

	"filter4Visiblity": (items) ->
		if items?
			if not isc.isA.Array(items)
				items = [items]
			items.filter (item) ->
				if item.submenu?
					if isc.isA.Object(item.submenu)
						item.submenu = isc.MenuSS.create
							items:item.submenu.items
					else if isc.isA.Menu(item.submenu)
						item.submenu = isc.MenuSS.create
							items:item.submenu.items

				if item.visibilityIf? and isc.isA.Function(item.visibilityIf)
					_visibility = item.visibilityIf()
					_visibility isnt false and _visibility isnt "hidden"
				else
					(not item.visibility? or (item.visibility isnt false and item.visibility isnt "hidden"))



	"initWidget": ->
		@items = @filter4Visiblity @items

		(@items = @items.map (item) => item.owner = @owner; item) if @owner? and @items?
		(@items = @items.map (item) => item.owner?.tabsSet = @tabsSet; item) if @tabsSet? and @items?

		@Super "initWidget", arguments
		return

	"setData": (data) ->
		if isc.Tree? and isc.isA.Tree(@filter4Visiblity(data))
			@setTreeData data, true
		else
			rv = @invokeSuper isc.Menu, "setData", @filter4Visiblity(data)

		delete @_heightCalculated;
		@

	"getItem1": (identifier) ->
		res = @data.filter (item) -> item.identifier is identifier

		if isc.isA.Array(res) and res.length is 0
			click: -> isc.error "Element '#{identifier}' not found."
		else
			res[0]

