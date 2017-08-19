isc.defineClass("RestDataSourceSS", isc.RestDataSource).addProperties
	updateData: (updatedRecord, callback, requestProperties) ->
		if isc.isA.Object(requestProperties) is false
			requestProperties =
				useSimpleHttp: true
		else
			requestProperties.useSimpleHttp = true

		if isc.isA.Function(callback) is false
			callback = -> undefined

		@Super "updateData", [updatedRecord, callback, requestProperties]
		return

	removeData: (updatedRecord, callback, requestProperties) ->
		if isc.isA.Object(requestProperties) is false
			requestProperties =
				useSimpleHttp: true
		else
			requestProperties.useSimpleHttp = true

		if isc.isA.Function(callback) is false
			callback = -> undefined

		@Super "removeData", [updatedRecord, callback, requestProperties]
		return

	transformRequest: (dsRequest) ->
		if dsRequest.operationType is "update"
			dsRequest.data = isc.addProperties {}, dsRequest.oldValues, dsRequest.data

		#call the parent method with the updated dsRequest
		@Super "transformRequest", dsRequest
	
	getLookupFileds : isc.getLookupFileds
	getForeignFields: isc.getForeignFields
