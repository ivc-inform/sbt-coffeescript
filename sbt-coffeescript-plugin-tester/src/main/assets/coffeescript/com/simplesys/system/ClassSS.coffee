simpleSyS = @simpleSyS

isc.Class.addProperties
	getIdentifier: -> @identifier or @getID()
	
	getComment: ->
		title = @title;
		
		if title?.toLowerCase().indexOf("untitled") is - 1
			title = undefined
		
		@comment or title or @getClassName()

###isc.Class.addMethods
	addProperties: ->
		isc.addPropertyList @, arguments
		return###

isc.Class.addClassProperties
	addGlobalSS: (propName, propValue) ->
		if propName? and propValue? then simpleSyS.objects[propName] = propValue
		return
	
	getObjectSS: (identifier) -> simpleSyS.objects[identifier]
	
	isNullOrUndefigned: (obj) -> not obj?
	
	fireCallback: `function (callback, argNames, args, target, catchErrors) {
        arguments.__this = this;
        if (callback == null) return;

        var undef;
        if (argNames == null) argNames = undef;

        var method = callback;
        if (isc.isA.String(callback)) {
            // callback specified as the name of a method on a known target
            if (target != null && isc.isA.Function(target[callback])) method = target[callback];
            // callback is a String expression
            else method = this._makeCallbackFunction(callback, argNames);

        } else if (isc.isAn.Object(callback) && !isc.isA.Function(callback)) {
            // Object containing (possibly) target, and either methodName or action to fire

            if (callback.caller != null) target = callback.caller;
            else if (callback.target != null) target = callback.target;

            // Pick up arguments from the callback directly, if passed that way.
            if (callback.args) args = callback.args;
            if (callback.argNames) argNames = callback.argNames;

            if (callback.method) method = callback.method;

            else if (callback.methodName && target != null) method = target[callback.methodName];
            else if (callback.action)
                method = this._makeCallbackFunction(callback.action, argNames);
        }

        // At this point the target (if one was passed in) is available under 'target', and
        // we've converted the callback to a function, if possible.
        if (!isc.isA.Function(method)) {
            this.logWarn(
                "fireCallback() unable to convert callback: " + this.echo(callback) +
                " to a function.  target: " + target + ", argNames: " + argNames +
                ", args: " + args
            );
            return;
        }

        // If no target was specified, fire it in the global scope

        if (target == null) target = window;
        // If the target has been destroyed, abort!
        else if (target.destroyed) {
            // NOTE: this isn't a warning scenario: destruction is normal, and callbacks are
            // commonly timers to do visual refreshes which don't matter if a component is
            // destroyed
            if (this.logIsInfoEnabled("callbacks")) {
                this.logInfo(
                    "aborting attempt to fire callback on destroyed target:" + target +
                    ". Callback:" + isc.Log.echo(callback) +
                    ",\n stack:" + this.getStackTrace()
                );
            }
            return;
        }

        // this causes anonymous callback functions to be labelled "callback" in stack traces.
        // Non-anonymous callbacks still show their usual name
        method._isCallback = true;

        if (args == null) args = [];

        if (isc.enableCrossWindowCallbacks && isc.Browser.isIE) {
            var targetWindow = target.constructor ? target.constructor._window : target;
            if (targetWindow && targetWindow != window && targetWindow.isc) {
                var newArgs = targetWindow.Array.newInstance();
                for (var i = 0; i < args.length; i++) newArgs[i] = args[i];
                args = newArgs;
            }
        }

        var returnVal;

        if ((!catchErrors && !isc.Log.rethrowErrors) || isc.Log.supportsOnError) {
            returnVal = method.apply(target, args);
        } else {
            try {
                returnVal = method.apply(target, args);
            } catch (e) {
                if (catchErrors)
                    isc.Log._reportJSError(e);
                else
                    isc.Log._onRethrowError(e);

                //<editor-fold desc="Fixed by Y.Andrew">
                /*if (e.stack)
                 isc.Log.logError(e.stack)
                else if (e)
                    isc.Log.logError(e)*/
                //</editor-fold>
                throw e;
            }
        }

        return returnVal;
    }`

