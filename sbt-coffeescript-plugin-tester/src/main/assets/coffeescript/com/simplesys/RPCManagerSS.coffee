simpleSyS = @simpleSyS

simpleSyS.config ?= {
	defaultTimeout: 240000
	maxErrorMessageLength: 10000
	timeoutErrorMessage: "Время операции истекло (("
}

simpleSyS.app ?= {
	ViewLoaderC: -> undefined
	logining: {
		URILOGIN: "logic/login"
		URILOGOUT: "logic/logout"
	}
}

isc.RPCManager.addClassProperties
		
	"handleError": (response, request) ->
		if response.status is isc.RPCResponse.STATUS_LOGIN_REQUIRED
			if isc.RPCManager.loginRequired?
				isc.RPCManager.loginRequired(response, request)
			else if isc.RPCManagerSS.loginRequired?
							isc.RPCManagerSS.loginRequired(response, request)
		else
			if response.data?.data?
				response.data = response.data.data
			
			if response.data? and isc.isA.String(response.data) is true
				message = response.data
				if isc.isA.String(message) is true
					messageToShow = message
					if messageToShow.length > @maxErrorMessageLength
						delta = messageToShow.length - @maxErrorMessageLength
						messageToShow =
							messageToShow.substring(0, @maxErrorMessageLength) +
								"<br><br>...(#{delta} bytes truncated - set isc.RPCManager.maxErrorMessageLength > #{@maxErrorMessageLength} to see more or check the Developer Console for full error)..."
				
				###isc.error messageToShow, "958c9eec-999a-92a1-b3a7-2877a657ec55"###
			else
				if response.errorStruct?.error?
					response.data.error = response.errorStruct.error
					
				if response.data?.error?
					if isc.isA.Array(response.data.error) is true
						isc.error "Ошибка: #{response.data.error.length} элемента."
					else if response.data.error.message isnt strEmpty
						isc.ErrorDetail response.data.error.message, response.data.error.stackTrace, "958c9eec-999a-92a1-b3a7-2877a657ec33", "a338970d-416a-96e5-0842-685fd76052d8"
				else
					codeName = isc.getKeyForValue response.status, isc.RPCResponse.errorCodes
					if isc.isA.String(codeName) is true
						if codeName.startsWith("STATUS_") is true then codeName = codeName.substring(7)
					else
						codeName = if response.status? then "error code: #{response.status}" else "unknown error code"
					
					opName = response.operationId or response.operationType
					extraText = strEmpty
					
					switch codeName
						when "MAX_FILE_SIZE_EXCEEDED"
							message = isc.DataSource.maxFileSizeExceededMessage.evalDynamicString(
								@,
								maxFileSize: response.maxFileSize
									uploadedFileName: response.uploadedFileName
									uploadedFileSize: response.uploadedFileSize
							                                                                     )
							
							extraText = "#{newLine}Set rpcRequest.willHandleError:true on your request to handle this error yourself, or add a custom handleError to RPCManager to change system-wide default error reporting"
						
						when "VALIDATION_ERROR"
							message = "Server returned validation errors: " + isc.echoFull(response.errors)
							
							extraText = "#{newLine}Set rpcRequest.willHandleError:true on your request to handle this error yourself, or add a custom handleError to RPCManager to change system-wide default error reporting"
							
						when "FAILURE"
							if response.httpResponseText?
								data = isc.Class.evaluate(response.httpResponseText)
								if isc.isA.Array(data)
									data.forEach (data) ->
										err = data.data.error
										#isc.ErrorDetail err.message, err.stackTrace, "958c9eec-999a-92a1-b3a7-2877a657ec33", "a338970d-416a-96e5-0842-685fd76052d8"
						else
							message = "Server returned #{codeName} with no error message" + if opName? then " performing operation '#{opName}'." else "."
					
					#@reportError message
		
		@logWarn(message + extraText + " - response: #{@echo response}")
		return
					
	"evalResult": (request, response, results) ->
		if isc.isA.Function results.match
			evalVars = request.evalVars
			@logDebug ("evaling result" + if evalVars? then " with evalVars: #{isc.Log.echo(evalVars)}" else strEmpty)
			
			origAutoDraw = isc.Canvas.getInstanceProperty "autoDraw"
			if request.suppressAutoDraw
				isc.Canvas.setInstanceProperty "autoDraw", false
			
			if results.match(new RegExp("^\\s*\\{"))
				results = "var evalText=#{results};evalText;"
			
			evalResult = isc.Class.evalWithVars results, evalVars
			if request.suppressAutoDraw
				isc.Canvas.setInstanceProperty "autoDraw", origAutoDraw
			
			evalResult
	
	"sendRequest": `function (request) {
        // for Developer Consoel RPC->Call Stack view
        if ((this._trackRPC || !this._initializedTrackRPC) && !request.doNotTrackRPC) {
            try {
                request._callStack = this.getStackTrace();
            } catch (e) {
                request._callStack = "N/A due to: " + e;
            }
        }
        // handle call to sendRequest with useHttpProxy explicitly set - you're really supposed
        // to call sendProxied() but this is a common mistake.  Checking for the isProxied flag
        // avoids a loop since sendProxied() calls sendRequest() after reformatting the
        // request.
        if (request.useHttpProxy && !request.isProxied) return this.sendProxied(request);

        // we are delaying transactions and this is a periodic polling or similar request that
        // can be ignored in this circumstance, so drop it
        if (request.canDropOnDelay && this.delayingTransactions) return;

        // make a copy of the request to allow callers to re-use the same object, with
        // modifications, when calling sendRequest() - note: shallow copy
        request = isc.addProperties({}, request);

        // default is true, so set it unless it's been explicitly disabled
        if (request.suppressAutoDraw !== false) request.suppressAutoDraw = true;

        // actionURL can also be specified as URL or url
        request.actionURL =
            // NOTE use Page.getURL() to support special directories such as "[APPFILES]"
            isc.Page.getURL(
                request.actionURL || request.url ||
                request.URL || (this.getActionURL && this.getActionURL())
            );

        // check if requested transport is available and fall back if necessary
        // ---------------------------------------------------------------------------------------

        // if the request specifies an explicit transport, we use that.  Otherwise, check
        // backcompat APIs first, then use RPCManager.defaultTransport
        var explicitTransport = request.transport;
        if (!explicitTransport) {
            if (request.useXmlHttpRequest != null || this.useXmlHttpRequest != null) {
                // use of backcompat API on RPCRequest or RPCManager
                if (request.useXmlHttpRequest == null) {
                    if (this.useXmlHttpRequest != null) {
                        request.transport = this.useXmlHttpRequest ? "xmlHttpRequest" : "hiddenFrame";
                    } else {
                        request.transport = this.defaultTransport;
                    }
                } else {
                    request.transport = explicitTransport = request.useXmlHttpRequest ? "xmlHttpRequest" : "hiddenFrame";
                }
            } else {
                request.transport = this.defaultTransport;
            }
        }

        // Verify that the transport is available
        this.checkTransportAvailable(request, (explicitTransport != null));

        //>!BackCompat 2007.2.14 paramsOnly renamed to useSimpleHttp
        if (request.useSimpleHttp == null) request.useSimpleHttp = request.paramsOnly;
        //<!BackCompat

        // default prompt-related settings on request to RPCManager defaults
        // ---------------------------------------------------------------------------------------
        isc.addDefaults(
            request, {
                showPrompt              : this.showPrompt,
                promptStyle             : this.promptStyle,
                promptCursor            : this.promptCursor,
                useCursorTracker        : this.useCursorTracker,
                cursorTrackerConstructor: this.cursorTrackerConstructor
            }
        );

        request.cursorTrackerProperties = isc.addProperties(
            {}, this.cursorTrackerDefaults,
            this.cursorTrackerProperties,
            request.cursorTrackerProperties
        );

        if (request.cursorTrackerProperties == null)
            request.cursorTrackerProperties = this.cursorTrackerProperties;

        // if request.operation is supplied by callers doing DataSource operations.  If not
        // supplied, add it so we can assume its there for logging, etc.
        if (!request.operation) {
            request.operation = {
                ID  : "custom",
                type: "rpc"
            }
        }

        var transformedData = this.transformRequest(request);
        // correct the common error of returning the rpcRequest itself incorrectly, which is
        // never right since the rpcRequest contains various widgets and other data
        // inappropriate to send to the server.
        if (transformedData !== request) {
            request.data = transformedData;
        }

        // track (globally and per-DBC) outstanding RPCRequests
        // Do not increment pendingRpcs if the request has downloadResult set to true
        // because in this case we will never receive a callback to decrease the value
        if (!request.downloadResult) this.pendingRpcs++;

        if (request.componentId) {
            request._component = window[request.componentId];
            if (request._component) request._component._pendingRpcs++;
        }

        if (this.canQueueRequest(request, (explicitTransport != null))) {
            if (!this.currentTransaction) this.currentTransaction = this._createTransaction(request.doNotTrackRPC);
            this._addRequestToTransaction(request, this.currentTransaction);
            // if we're not queuing, send it off
            if (!this.queuing) return this.sendQueue();
            return request;

        } else {
            return this.sendNoQueue(request);
        }
    }`

isc.defineClass("RPCManagerSS", isc.RPCManager).addClassProperties
	"defaultTimeout": simpleSyS.config.defaultTimeout
	"maxErrorMessageLength": simpleSyS.config.maxErrorMessageLength
	"timeoutErrorMessage": simpleSyS.config.timeoutErrorMessage
	
	"mainPageNotLogged": simpleSyS.config.mainPageNotLogged
	"mainPageLogged": simpleSyS.config.mainPageLogged
	
	"sendRequest": (request, evalResult) ->
		if request? and isc.isA.Object(request) is true
			request.useSimpleHttp = true
			request.httpMethod = "POST"
			##request.willHandleError = true
			request.evalResult = if not evalResult? then true else evalResult
			request.params =
				isc_dataFormat: "JSON"
			if isc.isA.Object(request.data) is true
				request.data = isc.JSONSS.encode request.data, "prettyPrint": false
			else if isc.isA.String(request.data) is false
				request.data = {}
			
			@Super "sendRequest", [request]
		else
			@Super "sendRequest", arguments
		return
	
	"loginRequired": (reload, loginSuccessProcedure) ->
		if isc.isA.Function(reload)
			loginSuccessProcedure = reload
			reload = true
		else if isc.isA.Boolean(reload)
			if not reload? then reload = true
		else
			reload = true
		
		if isc.isA.LoginWindow isc.RPCManagerSS.loginWindow
			isc.RPCManagerSS.loginWindow.markForDestroy()
			isc.RPCManagerSS.loginWindow = null
		
		isc.RPCManagerSS.loginWindow = isc.LoginWindow.create
			"loginSuccessProcedure": if isc.isA.Function(loginSuccessProcedure) then loginSuccessProcedure else undefined
			"mainPageLogged": @mainPageLogged
			"reload": reload
		
		return
	"logoutRequired": () ->
		delete simpleSyS.app.login
		delete simpleSyS.app.userId
		delete simpleSyS.app.codeGroup
		delete simpleSyS.app.userId
		delete simpleSyS.simpleSysContextPath
		
		simpleSyS.app.ViewLoaderC?.setViewURL? @mainPageNotLogged
		return


	    
