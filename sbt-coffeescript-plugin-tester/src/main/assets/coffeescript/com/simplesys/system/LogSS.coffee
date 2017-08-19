simpleSyS = @simpleSyS

_logMethods =
	_reportJSErrorStack: (message) ->
		@logWarn1 message
		return

	logMessage: (priority, message, category, timestamp) ->
		log = isc.Log;
		if log?
			priority = log.defaultPriority unless priority
			
			if priority <= log.stackTracePriority and @getStackTrace?
				message += "\nStack trace:\n#{@getStackTrace(arguments, 2)}"

			category = @Class unless category

			idString = @ID
			if isc.FormItem and isc.isA.FormItem(@) and @name?
				idString += "[#{@name}]"

			log.log priority, message, category, idString, @, timestamp

			if log.isEnabledFor(category, priority, @)
				log._makeLogMessage(priority, message, category, idString, timestamp);

	logDebug: (message, category) ->
		message = @logMessage isc.Log.DEBUG, message, category
		if message?
			console.log message
		message

	logInfo: (message, category) ->
		message = @logMessage isc.Log.INFO, message, category
		if message?
			console.info message
		message

	logWarn: (message, category) ->
		message = @logMessage isc.Log.WARN, message, category
		if message?
			console.warn message
		message

	logWarn1: (message, category) ->
		message = @logMessage isc.Log.WARN, message, category
		if message?
			console.error message
		message

	logError: (message, category) ->
		message = @logMessage isc.Log.ERROR, message, category
		if message?
			console.error message
		message

	logFatal: (message, category) ->
		message = @logMessage isc.Log.FATAL, message, category
		if message?
			console.error message
		message

	setLogPriority: (category, priority) ->
		isc.Log.setPriority category, priority, @
		return

	addToMasterLog: -> a = 0; return

isc.Class.addMethods _logMethods
isc.Class.addClassMethods _logMethods

isc.Log.addClassMethods
	addToMasterLog: `function (message) {

        //if (window.console != null) window.console.warn("*" + message);

        //!DONTOBFUSCATE
        // NOTE: we're not obfuscating so the "message" parameter will retain that name later
        // remember the message passed in
        this._messageCache[this._messageIndex] = message;

        // set up for the next message
        this._messageIndex++;

        // if we're beyond the appropriate number of messages to remember
        if (this._messageIndex > this.messageCount) {
            // roll over the messsageIndex to 0
            this._messageIndex = 0;
        }
        if (this.showInlineLogs) {
            this.updateInlineLogResults();
        }
    }`
