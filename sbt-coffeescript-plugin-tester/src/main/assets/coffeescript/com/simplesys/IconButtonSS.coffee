isc.defineClass("IconButtonSS", isc.IconButton).addProperties
	"canFocus": true
	"autoDraw": false
	"keyPress": ->
		key = isc.Event.getKey()
		switch key
			when "Escape"
				if @parentElement.showCloseButton is true
					@escapeKeyPress?()

			else
				@Super "keyPress", arguments

	"draw"    : ->
		@Super "draw", arguments
		if @focused is true then @focus(); return
	"focused": false
