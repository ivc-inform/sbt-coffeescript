isc.defineClass("HTMLPaneSS", isc.HTMLPane).addProperties
	"autoDraw"   : false
	"clearContents": ->
		@setContents "&nbsp;"
		return

	"addContents": (contents) ->
		if @contents is "&nbsp;"
			@setContents "#{contents}";
		else
			@setContents "#{@contents}<p>#{contents}";
		return
