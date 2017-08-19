isc.defineClass("IconMenuButtonSS", isc.IconMenuButton).addProperties
	"autoDraw"  : false
	"initWidget": ->
		this.Super "initWidget", arguments

		if @menu? and isc.isA.Array(@menu.items)
			_items = @menu.items
			@menu = isc.MenuSS.create
				items: _items
		return