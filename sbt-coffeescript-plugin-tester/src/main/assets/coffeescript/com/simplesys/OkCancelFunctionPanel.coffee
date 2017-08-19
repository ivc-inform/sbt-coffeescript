simpleSyS = @simpleSyS

isc.defineClass("OkCancelFunctionPanel", isc.HPanelSS).addProperties
	"defaultLayoutAlign" : "center"
	"autoDraw"           : false
	"ownerDestroy"       : true
	"functionButtonTitle": "Операции ..."
	"okButtonTitle"      : "Выполнить ..."
	"cancelButtonTitle"  : "Отменить ..."
	"setDisabledOk"      : (value) -> @okBtn.setDisabled(value); return
	"initWidget"         : ->
		@Super "initWidget", arguments

		@addMembers [
			            isc.LayoutSpacerSS.create
				            "width": "*"

			            @okBtn = isc.IButtonSS.create
				            click             : =>
					            @okFunction?()
					            simpleSyS?.checkOwner?(@owner)
					            @owner?.okFunction? @filterBuilder;
					            if @ownerDestroy is true
						            @owner?.markForDestroy?()
					            ###else
						            @owner?.hide?()###
					            return
				            "title"           : @okButtonTitle
				            "prompt"          : @okButtonTitle
				            "icon"            : "ok.png"
				            "width"           : 100
				            "showDisabledIcon": true

			            isc.LayoutSpacerSS.create
				            "width": "*"

			            isc.IButtonSS.create
				            "click"           : =>
					            @functionFunction?()
					            simpleSyS.checkOwner @owner
					            @owner?.functionFunction? @filterBuilder
					            return
				            "title"           : @functionButtonTitle
				            "prompt"          : @functionButtonTitle
				            "icon"            : "function-selection.png"
				            "width"           : 100
				            "showDisabledIcon": true

			            isc.LayoutSpacerSS.create
				            "width": "*"

			            isc.IButtonSS.create
				            "click"           : =>
					            @cancelFunction?()
					            simpleSyS?.checkOwner?(@owner)
					            @owner?.cancelFunction? @filterBuilder
					            @owner?.markForDestroy?()
					            return
				            "title"           : @cancelButtonTitle
				            "prompt"          : @cancelButtonTitle
				            "icon"            : "cancel.png"
				            "width"           : 100
				            "showDisabledIcon": true

			            isc.LayoutSpacerSS.create
				            "width": "*"
		            ]
		return

