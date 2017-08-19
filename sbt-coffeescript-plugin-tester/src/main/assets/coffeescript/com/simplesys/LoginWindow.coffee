simpleSyS = @simpleSyS

isc.defineClass("LoginWindow", isc.WindowSS).addProperties

	"doLogin": (form) ->
		if form.validate() is true
			password = form.getItem("password").getValue()
			login = form.getItem("login").getValue()

			isc.RPCManagerSS.sendRequest
				"timeout" : 60000
				"sendNoQueue" : true
				"callback"     : (rpcResponse) =>
					data = rpcResponse.data
					if not data?
						@logWarn("rpcResponse: #{isc.JSON.encode(rpcResponse, prettyPrint: true)}")
						##@doLogin form
					else
						failure = () ->
							form.setValue "loginFailure", errorMessage
							form.showItem "loginFailure"
							form.focusInItem "login"
							if form.loginSuccessProcedure?
								form.loginSuccessProcedure(false)
							return

						if data? and data.data?
							data = data.data if isc.isA.Object data.data
							status = data.status;
							errorMessage = data.errorMessage

							if status is isc.RPCResponse.STATUS_SUCCESS

								isc.OfflineSS.put "#{@getIdentifier()}login", login

								loginItem = form.getItem "login"

								if loginItem.valueMap?
									if not loginItem.valueMap.contains login
										loginItem.valueMap.add login

									_values = (loginItem.valueMap.filter (item) -> item?).sort()
									loginItem.setValueMap _values

									isc.OfflineSS.putArray "#{@getIdentifier()}logins", _values

								if @savePassword
									isc.OfflineSS.put "#{@getIdentifier()}#{login}password", password

								simpleSyS.app.login = login
								simpleSyS.app.password = password
								simpleSyS.app.userId = data.userId
								simpleSyS.app.codeGroup = data.codeGroup
								simpleSyS.app.captionUser = data.captionUser
								@simpleSysContextPath = data.simpleSysContextPath
								simpleSyS.simpleSysContextPath = data.simpleSysContextPath

								isc.OfflineSS.put "#{@getIdentifier()}codeGroup", simpleSyS.app.codeGroup

								form.hideItem "loginFailure"
								@markForDestroy()

								if @reload is true
									if form.loginSuccessProcedure?
										form.loginSuccessProcedure(true, data.captionUser, data.codeGroup)
									else
										simpleSyS.app.ViewLoaderC?.setViewURL? @mainPageLogged
							else
								failure()
						else
							failure()
					return

				"actionURL": simpleSyS.app.logining.URILOGIN
				"data"   :
					"password": password
					"login"   : login
		return

	"isModal"           : true
	"identifier"        : "4E716784-FD33-068A-1176-FCF2686908E5"
	"modalMaskOpacity"  : 70
	"showMinimizeButton": false
	"showMaximizeButton" : false
	"showCloseButton" : false
	"autoSize"          : true
	"headerIconPath"    : "key-login-icon.png"
	"title"             : "Аутентификация..."
	"initWidget"        : ->
		@Super "initWidget", arguments
		if not simpleSyS?
			simpleSyS = {
				app: {}
				devGroup: -> true
			}
		else if not isc.isA.Function simpleSyS.devGroup
			simpleSyS.devGroup = -> true

		@login = isc.OfflineSS.get "#{@getIdentifier()}login"
		@codeGroup = isc.OfflineSS.get "#{@getIdentifier()}codeGroup"
		@savePassword = isc.OfflineSS.getBoolean "#{@getIdentifier()}#{@login}savePassword", false

		@loginForm = isc.DynamicFormSS.create
			"autoDraw" : false
			"autoFocus": true
			"loginSuccessProcedure": @loginSuccessProcedure
			"fields"   : [
				{
					"colSpan"   : 2
					"visible"   : false
					"name"      : "loginFailure"
					"align"     : "center"
					"cellStyle" : "formCellError"
					"titleStyle": "Error"
					"wrap"      : true
					"width"     : 250
					"editorType": "BlurbItem"
				}
				{
					"required": true
					"type"    : if simpleSyS.devGroup(@codeGroup) then "ComboboxItemWithClearButton" else "text"
					changed   : (form, item, value) =>
						if isc.isA.ComboBoxItem(item)
							@loginForm.hideItem "loginFailure"
							password = isc.OfflineSS.get "#{@getIdentifier()}#{value}password"
							@loginForm.setValue "password", password
						return

					"keyPress"           : (item, form, keyName)->
						if keyName is "Enter"
							form.focusInItem "password"
							return false

						form.hideItem "loginFailure"
						return
					"name"               : "login"
					"title"              : "\u041B\u043E\u0433\u0438\u043D"
					"requiredMessage"    : "\u041F\u043E\u043B\u0435 '\u041B\u043E\u0433\u0438\u043D' \u0434\u043E\u043B\u0436\u043D\u043E \u0431\u044B\u0442\u044C \u0437\u0430\u043F\u043E\u043B\u043D\u0435\u043D\u043E."
					"width"              : 250
					"value"              : @login
					"_showValueAfterDraw": -> undefined; return
					"onButtonClearClick" : (value) =>
						loginItem = (@loginForm.getItem "login")
						login = value

						(@loginForm.getItem "password").clearValue()
						isc.OfflineSS.remove "#{@getIdentifier()}#{login}password"

						if loginItem.valueMap?
							loginItem.valueMap.remove login

							_values = (loginItem.valueMap.filter (item) -> item?).sort()
							loginItem.setValueMap _values

							isc.OfflineSS.putArray "#{@getIdentifier()}logins", _values

						return
					"valueMap"           : (isc.OfflineSS.getArray "#{@getIdentifier()}logins").sort() if simpleSyS.devGroup(@codeGroup)
				}
				{
					"required"       : true
					"keyPress"       : (item, form, keyName, characterValue) =>
						if keyName is "Enter"
							@doLogin form
							return false

						form.hideItem "loginFailure"
						return
					"name"           : "password"
					"title"          : "\u041F\u0430\u0440\u043E\u043B\u044C"
					"width"          : 250
					"requiredMessage": "\u041F\u043E\u043B\u0435 '\u041F\u0430\u0440\u043E\u043B\u044C' \u0434\u043E\u043B\u0436\u043D\u043E \u0431\u044B\u0442\u044C \u0437\u0430\u043F\u043E\u043B\u043D\u0435\u043D\u043E."
					"editorType"     : "PasswordItem"
					"value"          : (isc.OfflineSS.get "#{@getIdentifier()}#{@login}password" if @savePassword)
				}
				{
					visible: simpleSyS.devGroup(@codeGroup)
					title  : "Сохранить пароль"
					name   : "savePassword"
					type   : "checkbox"
					value  : @savePassword
					changed: (form, item, value) =>
						isc.OfflineSS.putBoolean "#{@getIdentifier()}#{@login}savePassword", value
						@savePassword = value
						return
				}
			]

		@ed = isc.OkCancelPanelWithOutOwnerDestroy.create
			owner: @
			height: 35
			width: 306
			okCaption: "Войти ..."
			cancelCaption: "Отменить ..."
			ownerHide : false
			okFunction: =>
				@doLogin @loginForm
				return
			cancelFunction: ->
				isc.RPCManagerSS.logoutRequired()
				@owner.markForDestroy()
				return

		@addItems [@loginForm, @ed]
		@loginForm.focusInItem "login"

		return
	"showModalMask"     : true
	"autoCenter"        : true
