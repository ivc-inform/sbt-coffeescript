simpleSyS = @simpleSyS

isc.defineClass("OkCancelPanel", isc.HPanelSS).addProperties
	"defaultLayoutAlign": "center"
	"autoDraw"          : false
	"height"            : 28
	"okIcon"            : "ok.png"
	"cancelIcon"        : "cancel.png"
	"ownerDestroy"      : true
	"ownerHide"         : true
	"cancelCaption"     : "Отменить"
	"okCaption"         : "Выполнить"
	"timeoutClose"      : 1000
	"setDisabledOk"       : (value) -> @okBtn.setDisabled(value); @
	"setOwner"            : (owner) -> @owner = owner; @
	"initWidget"        : ->
		@Super "initWidget", arguments

		@addMembers [
						isc.LayoutSpacerSS.create
							"width": "*"

						@okBtn = isc.IButtonSS.create
							"autoFit": true
							"click": =>
								if isc.isA.Function @okFunction
									@okFunction @
								else
									if @owner?
										simpleSyS?.checkOwner? @owner
										@owner.okFunction? @
										if @ownerDestroy is true
											@owner?.markForDestroy?()
										else if @ownerHide is true
											@owner?.hide?()
								return

							"title"           : @okCaption
							"prompt"          : @okCaption
							"icon"            : @okIcon
							"width"           : 100
							"showDisabledIcon": false

						isc.LayoutSpacerSS.create
							"width": "*"

						@cancelButton = isc.IButtonSS.create
							"autoFit": true
							"click": =>
								if isc.isA.Function @cancelFunction
									@cancelFunction @
								else
									if @owner?
										simpleSyS?.checkOwner? @owner
										@owner?.cancelFunction? @
										if @ownerDestroy is true
											@owner?.markForDestroy?()
										else if @ownerHide is true
											@owner?.hide?()
								return

							"title": @cancelCaption
							"prompt": @cancelCaption
							"icon" : @cancelIcon
							"width": 100

						isc.LayoutSpacerSS.create
							"width": "*"
					]
		return

isc.defineClass("OkPanel", isc.HPanelSS).addProperties
	"defaultLayoutAlign": "center"
	"autoDraw": false
	"ownerDestroy": true
	"ownerHide": true
	"okCaption": "Выполнить"
	"okIcon"   : "ok.png"
	"timeoutClose": 1000
	setDisabledOk: (value) -> @okBtn.setDisabled(value); @
	setOwner: (owner) -> @owner = owner; @
	"initWidget": ->
		@Super "initWidget", arguments

		@addMembers [
			isc.LayoutSpacerSS.create
				"width": "*"

			@okBtn = isc.IButtonSS.create
				"autoFit": true
				"click": =>
					@okFunction? @
					if @owner?
						simpleSyS?.checkOwner? @owner
						@owner?.okFunction? @
						if @ownerDestroy is true
							@owner?.markForDestroy?()
						else if @ownerHide is true
							@owner?.hide?()
					return

				"title": @okCaption
				"icon":  @okIcon
				"width": 100
				"showDisabledIcon": false

			isc.LayoutSpacerSS.create
				"width": "*"
		]
		return
