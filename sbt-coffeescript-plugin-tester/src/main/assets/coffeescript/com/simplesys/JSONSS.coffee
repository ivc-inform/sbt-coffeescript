isc.JSON.addClassProperties
	decode: (jsonString, reviver) ->
		if not jsonString? or jsonString is ""
			jsonString = null
		try
			JSON.parse jsonString, reviver
		catch e
			console.error e.toString()
			{}

	encode: (object, settings) ->
		if settings?.prettyPrint is true
			spacer = 4

		try
			JSON.stringify object,
						   (key, value) =>
							   switch key
								   when "ns"
									   undefined
								   when "__proto__"
									   undefined
								   else
									   if isc.isA.Array value
                                           value
									   else
										   if isc.isA.Function value
											   undefined
										   else
											   if isc.isA.Object value
												   if isc.isA.Menu value
													   undefined
												   else if value.unserialize is true
													   undefined
												   else
													   value
											   else
												   value
						   , spacer
		catch e
			console.error e.toString()
			""
	printObject: (obj) ->
		try
			console.log isc.JSON.encode(obj)
		catch e
			console.log e.toString()
		return

isc.defineClass("JSONSS", isc.JSON).addClassProperties
	tryDecode: (jsonString, reviver) ->
		isc.JSON.decode jsonString, reviver
		return

	###encode: (object, settings)->
		settings ?= prettyPrint: false
		isc.JSON.encode object, settings###
