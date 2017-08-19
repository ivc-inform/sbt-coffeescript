isc.defineClass("PortletSS", isc.Portlet).addProperties
	"headerIconPath"    : ""
	"autoDraw"          : false
	"headerIconDefaults":
		"height": 14
		"width" : 16
	"setFuncMenu"       : (funcMenu) -> @funcMenu = funcMenu; return
	"initWidget"        : ->
		@Super "initWidget", arguments
		@headerIconDefaults.src = @headerIconPath
		return
	"getFuncMenu"       : -> @funcMenu