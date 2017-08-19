isc.defineClass("LookupEditor", isc.HLayoutSS).addProperties
	"autoDraw"    : false
	"height"      : "100%"
	"width"       : "100%"
	headerIconPath: "condition.png"
	"initWidget"  : ->
		@Super "initWidget", arguments

		@addMembers [
			            (
				            "width"  : "*"
				            "canEdit": false
				            click    : =>
					            if @owner?.grid?.selectionType isnt "multiple" or (not isc.EventHandler.ctrlKeyDown() and not isc.EventHandler.shiftKeyDown())
						            @owner.grid.deselectAllRecords()
					            @owner.grid.selectRecord @record
					            false
			            )
			            isc.IButtonSS.create
				            "iconAlign": "center"
				            "click"    : =>
					            @_lookupEditor = @foreignField.foreignKey.substring(0, @foreignField.foreignKey.lastIndexOf('.'))
					            @_lookupEditor = @_lookupEditor.substring(0, @_lookupEditor.lastIndexOf('_'))
					            @_pk = @foreignField.foreignKey.substring(@foreignField.foreignKey.lastIndexOf('.') + 1)

					            @_wrappedComponent = @evaluate "isc.Editor#{@_lookupEditor}.create({identifier: identifier, selectionType: selectionType})",
					                                           identifier: "#{@editorIdentifier}wrappedComponent"
					                                           selectionType: "single"

					            if isc.isA.TreeGridEditor(@_wrappedComponent)
						            @_wrappedComponent.grid.dataArrived = => @_wrappedComponent.selectSingleRecordByKey @record[@foreignField.name]; return
					            else if isc.isA.ListGridEditor(@_wrappedComponent)
						            @_wrappedComponent.grid.dataArrived = => @_wrappedComponent.selectSingleRecordByKey @record[@foreignField.name]; return
					            else
						            isc.Log.logError "Bad branch of #{@_wrappedComponent.getClassName()}"

					            isc.WindowWrapper.create
						            identifier      : @editorIdentifier
						            record          : @record
						            headerIconPath  : @headerIconPath
						            wrappedComponent: @_wrappedComponent
						            title              : @lookupFields[0].field_captionClassLookup if @lookupFields.length > 0
						            okFunction      : =>
							            @record[@foreignField.name] = @_wrappedComponent.getSelectedRecord()[@_pk]

							            @lookupFields.forEach (field) =>
								            @record[field.field_name] = @_wrappedComponent.getSelectedRecord()[field.field_name]
								            return

							            @owner.updateData @record
							            return
					            return

				            "icon" : @headerIconPath
				            "width": 25
		            ]

		return

