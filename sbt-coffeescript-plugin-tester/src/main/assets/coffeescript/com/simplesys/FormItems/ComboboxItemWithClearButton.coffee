isc.defineClass("ComboboxItemWithClearButton", isc.ComboboxItemWithButtons).addProperties

	constructor: "ComboBoxItem"
	
	buttonsProperties: [
		(
			width: 20
			icon: "cancel.png"
			identifier: "ButtonClear"
			click: ->
				that = if isc.isA.IButtonSS @ then @ else if isc.isA.ComboboxItemWithClearButton @ then @buttons[0] else undefined
			
				that?.combobox?.onButtonClearClick?(that.combobox.getValue())
				that?.combobox?.clearValue?()
				that?.hide?()
				return
		)
	]
	init: ->
		@Super "init", arguments
		@buttonClearClick = @buttons[0].click
		@buttonClearHide = => @setValue false; return

		if @changed?
			@_changed = @changed

		@changed = (form, item, value) =>
			@_changed? form, item, value

			if value isnt strEmpty
				form.owner.showButton "ButtonClear"

				return

		return
		
	setValue: (value) ->
		if value isnt undefined
			if value?
				@showButton "ButtonClear"
			else
				@hideButton "ButtonClear"
			@Super "setValue", [value]
		return
