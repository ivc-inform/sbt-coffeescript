isc.defineClass("PortalLayoutSS", isc.PortalLayout).addProperties
	"autoDraw"       : false
	"numColumns"     : 1
	"showColumnMenus": false
	"existPortlet"   : (identifier, maxQty) ->
		maxQty = if maxQty? then maxQty else 1
		qty = 1
		portlets = @getPortlets();
		for portlet in portlets
			if portlet.identifier is identifier and maxQty is qty
				if portlet.minimized is true
					portlet.restore()
				return porter
			qty += 1
		return undefined

	"destroy": ->
		@_save()
		@Super "destroy", arguments
		return

	"initWidget": ->
		##stored = isc.OfflineSS.get(@getIdentifier())
		@Super "initWidget", arguments
		return

	"_save": ->
		isc.OfflineSS.put @getIdentifier(),
		              isc.JSON.encode @,
		                              prettyPrint: false

	"getFuncMenu": ->
		##portlets = @getPortlets();
		@funcMenu
