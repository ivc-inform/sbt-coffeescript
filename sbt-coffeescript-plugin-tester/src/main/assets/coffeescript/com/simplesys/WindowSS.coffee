isc.Window.addProperties
	"calcXY_Window"        : ->
		left = isc.EventHandler.getX()
		top = isc.EventHandler.getY()

		if left + @width > isc.Page.getWidth()
			@setLeft left - @width
		else
			@setLeft left

		if top + @height > isc.Page.getHeight()
			@setTop top - @height
		else
			@setTop top
		return
	"autoPosition"         : false
	"savePosition"         : true
	"saveSize"             : true
	"dismissOnEscape"      : true
	"vertical"             : true
	###"keyDown" : ->
		switch isc.EventHandler.getKey()
			when "Escape"
				@markForDestroy() if @dismissOnEscape
		true###
	"saveParams"           : -> @_save(); return
	"_save"                : ->
		if @items?
			@items.forEach (item) -> item?._save?(); return

		if @autoCenter isnt true and @autoPosition isnt true
			if @savePosition is true
				isc.OfflineSS.putNumber "#{@getIdentifier()}left", @getLeft()
				isc.OfflineSS.putNumber "#{@getIdentifier()}top", @getTop()

		if @saveSize is true
			isc.OfflineSS.putNumber "#{@getIdentifier()}width", @getWidth()
			isc.OfflineSS.putNumber "#{@getIdentifier()}height", @getHeight()

		return

isc.defineClass("WindowSS", isc.Window).addProperties
	"animateMembers": true
	"keepInParentRect": true
	"headerIconDefaults":
		"height": 14,
		"width": 16
	"animateMinimize": true
	"canDragResize": true
	###"resized" : ->
		return###
	"destroy"           : ->
		@_save?()
		@onDestroy? @typeButton
		@Super "destroy", arguments
		return

	"showMaximizeButton": true
	"closeClick"        : ->
		@_save?()
		@onDestroy? @typeButton
		@Super "closeClick", arguments

	"initWidget": ->
		@Super "initWidget", arguments
		@headerIconDefaults.src = @headerIconPath

		if @autoCenter isnt true and @savePosition is true
			if isc.OfflineSS.get("#{@getIdentifier()}top")? and isc.OfflineSS.get("#{@getIdentifier()}left")?
				top = isc.OfflineSS.getNumber "#{@getIdentifier()}top", @top
				left = isc.OfflineSS.getNumber "#{@getIdentifier()}left", @left

				@moveTo Math.max(left, 0), Math.max(top, 0)
			else
				@centerInPage()
		###top = isc.Page.getHeight() / 2 - @getHeight() / 2
		left = isc.Page.getWidth() / 2 - @getWidth() / 2###

		if @autoSize is false && @saveSize is true
			width = isc.OfflineSS.getNumber "#{@getIdentifier()}width", @width
			height = isc.OfflineSS.getNumber "#{@getIdentifier()}height", @height
			parent = if @parentElement? then @parentElement else isc.Page

			if @getLeft() + width > parent.getWidth()
				width = parent.getWidth() - @getLeft()

			if @getTop() + height > parent.getHeight()
				height = parent.getHeight() - @getTop()

			@setWidth width
			@setHeight height

		if @autoPosition is true
			@calcXY_Window?()
			
		@observe(@, "resized", @_save)
		@observe(@, "moved", @_save)
		return
	show        : ->
		@Super "show", arguments
		@bringToFront()
		return

