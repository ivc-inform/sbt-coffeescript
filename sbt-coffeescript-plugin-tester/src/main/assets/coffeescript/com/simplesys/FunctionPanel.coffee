isc.defineClass("FunctionPanel", isc.HPanelSS).addProperties
	"defaultLayoutAlign": "center"
	autoDraw            : false
	"initWidget"        : ->
		@Super "initWidget", arguments
		@addMembers [
			            isc.LayoutSpacerSS.create
				            "width" : "*"

			            isc.IButton.create
				            "click": =>
					            if @owner.functionFunction? then @owner.functionFunction(); return
					            if @functionFunction? then @functionFunction(); return

				            "autoDraw"        : false
				            "title"           : if @buttonTitle? then @buttonTitle else "Операции..."
				            "icon"            : "function-selection.png"
				            "width"           : 100
				            "showDisabledIcon": false

			            isc.LayoutSpacerSS.create
				            "width" : "*"
		            ]
		return
