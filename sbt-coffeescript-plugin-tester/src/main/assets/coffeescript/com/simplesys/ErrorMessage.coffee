simpleSyS = @simpleSyS

isc.defineClass("MessageWindow1", isc.WindowSS).addProperties
	"autoDraw"          : false
	"isModal"           : true
	"destroy"           : ->
		if isc.isA.Function @callback
			@callback()
		@Super "destroy", arguments
		return
	"showMinimizeButton": false
	"showMaximizeButton": false
	"autoSize"          : true
	###"autoPosition"       : true###
	"canDragReposition" : true
	"showHeaderIcon"   : false
	"title"             : "\u041E\u0448\u0438\u0431\u043A\u0430 ..."
	"showStatusBar"     : false
	"height"            : 50
	"dismissOnEscape" : true
	"initWidget"        : ->

		if isc.isA.Boolean @callback
			@autoPosition = @callback

		if isc.isA.Boolean @identifier
			@autoPosition = @identifier
			@identifier = undefined

		if isc.isA.Function @identifier
			@callback = @identifier
			@identifier = undefined

		@Super "initWidget", arguments


		if not @message? then @message = "&nbsp;"

		@addItem isc.VLayoutSS.create
			         "members": [
				         isc.HLayoutSS.create
					         "defaultLayoutAlign": "center"
					         "members": [
						         isc.VLayoutSS.create
							         "defaultLayoutAlign": "center"
							         "members": [
								         isc.Img.create
									         "src": @iconPath
									         "height": 32
									         "width": 32
							         ]
							         "align": "center"
							         "width": 50
						         isc.HTMLFlow.create
							         "contents": @message
							         "width": "*"
					         ]
				         isc.HLayoutSS.create
					         "defaultLayoutAlign": "center"
					         "members": [
						         isc.IButtonSS.create
							         "focused": true
							         "click": =>
								         @markForDestroy()
								         return
							         "title": "\u0417\u0430\u043A\u0440\u044B\u0442\u044C ..."
							         "icon": "ok.png"
							         "height": "*"
							         "width": 100
					         ]
					         "align": "center"
					         "height": 35
			         ]
			         "height": "100%"
			         "width": "100%"
		return

isc.defineClass("MessageWindow2", isc.WindowSS).addProperties
	"autoDraw": false
	"isModal" : true
	"iconPath": "error.png"
	"destroy" : ->
		if isc.isA.Function @callback
			@callback()
		@Super "destroy", arguments
		return
	"showMinimizeButton": true
	"showMaximizeButton": false
	"canDragResize"     : true
	"autoSize"          : false
	###"autoPosition"       : true###
	"canDragReposition" : true
	"showHeaderIcon"    : false
	"title"             : "\u041E\u0448\u0438\u0431\u043A\u0438 ..."
	"showStatusBar"     : false
	"height"            : 300
	"width"             : 600
	"dismissOnEscape" : true
	"initWidget"        : ->
		@Super "initWidget", arguments
		if not @message? then @message = "&nbsp;"
		@addItem isc.VLayoutSS.create
					 "members": [
						 isc.HLayoutSS.create
							 "defaultLayoutAlign": "center"
							 "members"           : [
								 isc.VLayoutSS.create
									 "defaultLayoutAlign": "center"
									 "members"           : [
										 isc.Img.create
											 "src"   : @iconPath
											 "height": 32
											 "width" : 32
									 ]
									 "align"             : "center"
									 "width"             : 50
								 isc.ListGrid.create
									 "showRecordComponentsByCell": true
									 "showRecordComponents"      : true
									 "data"                      : @errors
									 "fields"                    : [
										 {
											 "canEdit": false
											 "name"   : "message"
											 "title"  : "\u041E\u0448\u0438\u0431\u043A\u0430 (\u043A\u0440\u0430\u0442\u043A\u043E)"
											 "width"  : 300
										 }
										 {
											 "canEdit": false
											 "name"   : "stackTraceBtn"
											 "align"  : "center"
											 "title"  : "\u041E\u0448\u0438\u0431\u043A\u0430 (Stack)"
											 "width"  : 120
										 }
										 {
											 "hidden": true
											 "name"  : "stackTrace"
										 }
										 {
											 "hidden": true
											 "name"  : "stackTraceWindow"
										 }
									 ]
									 "createRecordComponent"     : (record, colNum) ->
										 fieldName = @getFieldName(colNum)

										 if (fieldName is "stackTraceBtn")
											 isc.IButton.create
												 height: 18
												 width : 130
												 icon  : "Detail.png"
												 title : "Подробности..."
												 click : ->
													 isc.error(record.stackTrace, "54366BDA-5F30-9772-82E6-CDF31AA36410")
													 return
									 "width"                     : "*"
							 ]
						 isc.HLayoutSS.create
							 "defaultLayoutAlign": "center"
							 "members"           : [
								 isc.IButtonSS.create
									 "focused"       : true
									 "click"         : =>
										 @markForDestroy()
										 return
									 "title"         : "\u0417\u0430\u043A\u0440\u044B\u0442\u044C ..."
									 "icon"          : "ok.png"
									 "height"        : "*"
									 "width"         : 100
							 ]
							 "align"             : "center"
							 "height"            : 35
					 ]
					 "height" : "100%"
					 "width"  : "100%"
		return

isc.defineClass("MessageWindow3", isc.WindowSS).addProperties
	"autoDraw": false
	"isModal" : true
	"iconPath": "info.png"
	"destroy" : ->
		if isc.isA.Function @callback
			@callback()
		@Super "destroy", arguments
		return
	"showMinimizeButton": false
	"showMaximizeButton": false
	"showCloseButton": true
	"canDragResize"     : true
	"autoSize"          : false
	###"autoPosition"       : true###
	"canDragReposition" : true
	"showHeaderIcon"    : false
	"title"             : "\u041E\u0448\u0438\u0431\u043A\u0438 ..."
	"showStatusBar"     : false
	"height"            : 300
	"width"             : 600
	"dismissOnEscape" : true
	"initWidget"        : ->
		@Super "initWidget", arguments
		if not @message? then @message = "&nbsp;"

		@grid = isc.ListGridEditor.create @gridProperties
		@addItem isc.VLayoutSS.create
					 "members": [
						 isc.HLayoutSS.create
							 "defaultLayoutAlign": "center"
							 "members"           : [
								 isc.VLayoutSS.create
									 "defaultLayoutAlign": "center"
									 "members"           : [
										 isc.Img.create
											 "src"   : @iconPath
											 "height": 32
											 "width" : 32
									 ]
									 "align"             : "center"
									 "width"             : 50
								 @grid
							 ]
						 isc.HLayoutSS.create
							 "defaultLayoutAlign": "center"
							 "members"           : [
								 isc.IButtonSS.create
									 "focused"       : true
									 "click"         : =>
										 @markForDestroy()
										 return
									 "title"         : "\u0417\u0430\u043A\u0440\u044B\u0442\u044C ..."
									 "icon"          : "ok.png"
									 "height"        : "*"
									 "width"         : 100
							 ]
							 "align"             : "center"
							 "height"            : 35
					 ]
					 "height" : "100%"
					 "width"  : "100%"
		return

isc.addGlobal "error", (message, identifier, callback) ->
	messageWindow = isc.MessageWindow1.create
		"iconPath"  : "error.png"
		"callback"  : callback
		"identifier": identifier
		"message"   : message
		"width"     : simpleSyS.getWidthMessageWindow message
	messageWindow.show()
	messageWindow

isc.addGlobal "info", (message, identifier, callback) ->
	messageWindow = isc.MessageWindow1.create
		"iconPath"  : "info.png"
		"callback"  : callback
		"identifier": identifier
		"message"   : message
		"title"     : "\u0418\u043D\u0444\u043E\u0440\u043C\u0430\u0446\u0438\u044F..."
		"width"     : simpleSyS.getWidthMessageWindow message
	messageWindow.show()
	messageWindow

isc.addGlobal "infos", (gridProperties, identifier, callback) ->
	messageWindow = isc.MessageWindow3.create
		"iconPath"  : "info.png"
		"callback"  : callback
		"identifier": identifier
		"gridProperties": gridProperties
		"title"     : "\u0418\u043D\u0444\u043E\u0440\u043C\u0430\u0446\u0438\u044F..."
	messageWindow.show()
	messageWindow

isc.addGlobal "ok", (message, identifier, callback) ->
	messageWindow = isc.MessageWindow1.create
		"iconPath"  : "ok.png"
		"callback"  : callback
		"identifier": identifier
		"message"   : message
		"title"     : "\u0412\u044B\u043F\u043E\u043B\u043D\u0435\u043D\u043E ..."
		"width"     : simpleSyS.getWidthMessageWindow message
	messageWindow.show()
	messageWindow

isc.addGlobal "errors", (errors, identifier, callback) ->
	messageWindow = isc.MessageWindow2.create
		"callback"  : callback
		"identifier": identifier
		"errors"    : errors
	messageWindow.show()
	messageWindow
