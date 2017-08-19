isc.ClassFactory.defineClass("ComboboxItemWithButtons", isc.CanvasItem).addProperties

	canFocus : true

	getValue: ->
		@comboboxItem.getValue()

	setValue: (value) ->
		if value isnt undefined
			@comboboxItem.setValue value
		return

	getClientPickListData: ->
		@comboboxItem.getClientPickListData()

	fetchData: (callback, requestProperties) ->
		@comboboxItem.fetchData callback, requestProperties
		return

	_visiblityButton: (identifier, action) ->
		button = (@buttons.filter (button) -> button.identifier is identifier).map (button) -> (button.setCanFocus false; button)
		if button.length > 0
			switch action
				when "show"
					button[0].show()
				when "hide"
					button[0].hide()
		return

	showButton: (identifier) ->
		@_visiblityButton identifier, "show"
		return

	hideButton: (identifier) ->
		@_visiblityButton identifier, "hide"
		return

	setValueMap: (valueMap) ->
		@comboboxItem.setValueMap valueMap
		return
		
	createCanvas: ->
		res = isc.HLayoutSS.create
			height : 20,
			members: [
				autoFitWidthApproach = if @autoFitWidthApproach then @autoFitWidthApproach else "both"

				df = isc.DynamicFormSS.create
					cellPadding: 0
					owner      : @
					width      : "*"
					minColWidth: 0
					colWidths  : [0, "*"]
					items      : [
						{
							colSpan: 2
							name: @name
							width: "*"
							showTitle: false
							onButtonClearClick: @onButtonClearClick
							addUnknownValues: @addUnknownValues
							optionDataSource: @optionDataSource
							_constructor: @constructor
							valueMap: @valueMap
							value: @value
							defaultValue: @defaultValue
							displayField: @displayField
							valueField: @valueField
							emptyPickListMessage: @emptyPickListMessage
							pickListFields: @pickListFields
							specialValues: @specialValues
							separateSpecialValues: @separateSpecialValues
							pickListWidth: @pickListWidth
							pickListMaxWidth: @pickListMaxWidth
							pickListProperties: @pickListProperties
							showRowNumbers: @showRowNumbers
							autoFitWidthApproach: autoFitWidthApproach
							changed: (form, item, value) =>
								@changed(form, item, value) if @changed?
								return
						}
					]
			]

		@comboboxItem = df.getItems()[0]
		@buttons = @buttonsProperties?.map (props) => isc.IButtonSS.create isc.addProperties(props, combobox: @comboboxItem)
		res.addMembers @buttons
		res.members = res.members.filter (item) -> item?
		res
