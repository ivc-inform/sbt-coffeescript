isc.defineClass("TabSetSS", isc.TabSet).addProperties
	"autoDraw": false
	"afterRemoveTabs" : -> undefined
	"beforeRemoveTabs" : (tab) -> undefined
	"filter4Visiblity": (tabs) ->
		if tabs?
			if isc.isA.Array(tabs) is false
				tabs = [tabs]
			_tabs = tabs.filter (item) -> (not item.visibility? or (item.visibility isnt false and item.visibility isnt "hidden"))
			_tabs

	addTabs: (tabs, position) ->
		if isc.isA.Array(tabs) is false
			tabs = [tabs]

		tabs.forEach (tab) ->
			if not tab.name? and tab.title?
				tab.name = tab.title
			return

		@Super "addTabs", [tabs, position]

		@tabs.forEach (tab) =>
			tab.tabSet = @
			return

		@tabs = @filter4Visiblity @tabs
		return

	addTab: (tab, position) ->
		@addTabs tab, position
		return

	removeTab: (tabs) ->
		if isc.isA.Number(tabs)
			tab = [@tabs[tabs]]
			tab[0].pane.onClose?()
		else if isc.isA.Array(tabs)
			tab = tabs
		else if isc.isA.Object(tabs)
			 tab = [tabs]

		tab.forEach (item) =>
			@beforeRemoveTabs item
			item.pane?.beforeRemove?()
			return

		@Super "removeTab", arguments
		@afterRemoveTabs()
		return

	removeAllTabs: () ->
		@removeTab @tabs
		return

	"localID" : (tab) -> "#{@getIdentifier()}_#{tab.name}"

	"_sortTabs": ()->
		if isc.isA.Array @tabs
			@tabs = (@tabs.map (tab) =>
				tab.index = isc.OfflineSS.getNumber(@localID(tab), 0)
				tab).sort (a, b) -> a.index - b.index

	"initWidget": ->
		@_sortTabs()
		@Super "initWidget", arguments
		return

	getLength: -> @tabs.length
	isEmpty: -> @tabs.length is 0
	isNotEmpty: -> @tabs.length isnt 0

	reorderTab: (tab, moveToPosition, savePos = true) ->
		tab.index = moveToPosition
		@Super "reorderTab", [tab, moveToPosition]
		if savePos
			@tabs.forEach (tab) => isc.OfflineSS.putNumber(@localID(tab), @getTabNumber(tab)); return
		return
