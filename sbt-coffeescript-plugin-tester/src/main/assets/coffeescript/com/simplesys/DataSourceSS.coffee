isc.DataSource.addProperties
		
	getForignKeyFieldsArray: ->
		res = []
		fks = @getForignKeyFields()
		for fk of fks
			res.add fk
		res
	
	getPrimaryKeyFieldsArray: ->
		res = []
		pks = @getPrimaryKeyFields()
		for pk of pks
			res.add pk
		res
	
	getForignKeyFields: ->
		forignKeys = {}
		fields = @getFields()
		for fieldName of fields
			fieldSpec = fields[fieldName]
			if fieldSpec.foreignKey?
				forignKeys[fieldName] = fieldSpec
		
		forignKeys
	
	getLookupFields: (forignKey)->
		lookupFields = {}
		fields = @getFields()
		for fieldName of fields
			fieldSpec = fields[fieldName]
			if fieldSpec.lookup is true and fieldSpec.foreignField is forignKey
				lookupFields[fieldName] = fieldSpec
		
		lookupFields
	
	getForignKeyFieldNames: (forignKey) -> isc.getKeys(@getLookupFields(forignKey))
	
	getLookupFieldNames: -> isc.getKeys(@getForignKeyFields())
	
	getItems: ->
		data = @getCacheData()
		if isc.isA.Array data
			data
		else
			[]
	
	clear: ->
		@getItems().forEach (item) =>
			pkFields = @getPrimaryKeyFields()
			data = {}
			
			if isc.isA.emptyObject pkFields
				@logWarn "Не найден первичный ключ, операция clear, не выполнена."
			else
				for value, pkField of pkFields
					data[pkField.name] = item[pkField.name]
				@removeData data unless isc.isA.emptyObject data
			return
		return
	
	isEmpty: ->
		@getItems().length is 0
	
	"isNotEmpty": -> not @isEmpty()

isc.defineClass("DataSourceSS", isc.DataSource).addClassProperties
	loaderSchemasURL: "[ISOMORPHIC]/LoadSchemas"
	
	loadComponentSchemas: (callback)->
		isc.RPCManagerSS.sendRequest
			"timeout" : 10000
			"sendNoQueue" : true
			callback: (response, data, request) =>
				if response.httpResponseCode is 404
					isc.error("The DataSourceLoader servlet is not installed.")
				else
					componentName = ""
					try
						dataArray = data.response.data
						if isc.isA.Array dataArray
							
							logPrty = @getDefaultLogPriority()
							@setLogPriority @getClassName(), isc.Log.DEBUG
							
							dataArray.forEach (item) =>
								if not isc.DataSource.get(item.component)?
									componentName = item.component
									obj = isc.Class.evaluate item.jsonStr
									
									if obj?
										@logDebug "Component schema: #{item.component} loaded."
									else
										@logDebug "Component schema: #{item.component} not loaded."
									return
							
							@setLogPriority @getClassName(), logPrty
						@getLogDataSources()
						if (callback)
							@fireCallback callback
					
					catch e
						isc.logWarn "Component: #{componentName} Encountered problems trying to loadComponentSchemas DataSources: #{isc.echoAll(e)}"
				return
			
			actionURL: isc.DataSourceSS.loaderSchemasURL
			data     :
				data:
					components: []
					ts        : isc.timeStamp()
		return
	
	load: (dsIDs, callback, forceReload) ->
		if not isc.isAn.Array(dsIDs)?
			dsIDs = [dsIDs]
		
		if dsIDs.length <= 0
			@logWarn("No DataSource IDs passed in.")
			return undefined
		
		loadThese = []
		
		for dsID in dsIDs
			if (@isLoaded(dsID))
				if forceReload?
					loadThese.add dsID
				else
					@logWarn "DataSource '#{dsID}' already loaded, use forceReload to reload such DataSources"
			else
				loadThese.add dsID
		
		if loadThese.length > 0
##post out to the DataSourceLoader servlet
			isc.RPCManagerSS.sendRequest
				callback: (rpcResponse, data) ->
##!OBFUSCATEOK
					if rpcResponse.httpResponseCode is 404
						isc.warn("The DataSourceLoader servlet is not installed.")
					else
						try
							obj = isc.Class.evaluate(data)
							
							if (callback)
								@fireCallback(callback, ["dsID"], dsIDs)
						catch e
							isc.logWarn "Encountered problems trying to load DataSources: #{isc.echoAll(e)}"
					return
				
				actionURL: isc.DataSourceSS.loaderURL
				data     :
					dataSources: loadThese
			return
		else
			if callback?
				@fireCallback callback, ["dsID"], dsID
				return
	
	combineCriteriaSS: (criteria1, criteria2, preserveCriteria, outerOperator, textMatchStyle) ->
		if not criteria1? then return criteria2
		if not criteria2? then return criteria1
		
		if not outerOperator? then outerOperator = "and"
		
		if outerOperator isnt "and" and outerOperator isnt "or"
			isc.logWarn "combineCriteria called with invalid outerOperator '#{outerOperator}'"
			return null
		
		## see if both criteria are simple and we can safely combine them as a simple Criteria
		## Note: can't use isAdvancedCriteria because it's an instance method
		if criteria1._constructor isnt "AdvancedCriteria" and criteria2._constructor isnt "AdvancedCriteria" and outerOperator is "and"
			for key, value of criteria1
				if criteria2[key]?
					advanced = true
					break
		
		else
			advanced = true
		
		## return simple criteria by straightforward combination
		if not advanced?
			return isc.addProperties {}, criteria1, criteria2
		
		## if either criteria is currently simple, upgrade it to advanced
		if criteria1._constructor is "AdvancedCriteria"
			advCrit1 = criteria1
		else
			advCrit1 = isc.DataSourceSS.convertCriteria criteria1, textMatchStyle
		
		if criteria2._constructor is "AdvancedCriteria"
			advCrit2 = criteria2
		else
			advCrit2 = isc.DataSourceSS.convertCriteria criteria2, textMatchStyle
		
		## join the two AdvancedCriteria together with the specified outerOperator
		aCrit = operator: outerOperator, _constructor: "AdvancedCriteria"
		
		## Optimization opportunity - if we were passed two criteria with the same
		## operator, and that operator is the same as "outerOperator", we can flatten
		## the structure by removing one intervening level.
		
		if not preserveCriteria? then preserveCriteria = "both"
		
		switch preserveCriteria
			when "none"
				if advCrit1.operator is outerOperator and advCrit2.operator is outerOperator
					aCrit.criteria = []
					aCrit.criteria.addAll(advCrit1.criteria)
					aCrit.criteria.addAll(advCrit2.criteria)
				else
					aCrit.criteria = [advCrit1, advCrit2]
			
			when "both"
				aCrit.criteria = [advCrit1, advCrit2]
			
			when "left"
				if advCrit2.operator is outerOperator
					aCrit.criteria = []
					aCrit.criteria.addAll(advCrit2.criteria)
					aCrit.criteria.add(advCrit1)
				else
					aCrit.criteria = [advCrit1, advCrit2]
			
			when "right"
				if advCrit1.operator is outerOperator
					aCrit.criteria = []
					aCrit.criteria.addAll(advCrit1.criteria)
					aCrit.criteria.add(advCrit2)
			else
				aCrit.criteria = [advCrit1, advCrit2]
		
		aCrit
	
	updateData: (updatedRecord, callback, requestProperties) ->
		if isc.isA.Object(requestProperties) is false
			requestProperties =
				useSimpleHttp: true
		else
			requestProperties.addProperties useSimpleHttp: true
		
		if isc.isA.Function(callback) is false
			callback = -> undefined
		
		@Super "updateData", [updatedRecord, callback, requestProperties]
		return
	
	getLogDataSources: ->
		for obj, dataSource of @_dataSources
			isc.Log.logDebug "DataSource ID: #{dataSource.getID()} loaded."
		return

isc._initBuiltInOperatorsSS = ->
	equality = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField) {

        if (dataSource._strictMode) {
            if (fieldValue == null || criterionValues.value == null) {
                return (this.negate ? !dataSource._withinLogicalNot : dataSource._withinLogicalNot);
            }
        }

        if (isc.isA.Date(criterionValues.value) && isc.isA.Date(fieldValue)) {
            return (dataSource.compareDates(criterionValues.value, fieldValue, fieldName) == 0);
        } else {
            return (criterionValues.value == fieldValue);
        }
    }`
	
	rangeCheck = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField, nullMeansNull) {
        var start = criterionValues.start || criterionValues.value;
        var end = criterionValues.end || criterionValues.value;

        if (dataSource._strictMode) {
            if (fieldValue == null || (this.lowerBounds && start == null) ||
                (this.upperBounds && end == null)) {
                return dataSource._withinLogicalNot;
            }
        }

        var lowerBoundsCheck = true;
        var upperBoundsCheck = true;
        var isDate = isc.isA.Date(fieldValue);
        var isNumber = isc.isA.Number(fieldValue);
        var isString = isc.isA.String(fieldValue);

        if (this.lowerBounds && start && ((isNumber && isNaN(start)) ||
            (start && isDate && (!isc.isA.Date(start))) ||
            (start && isString && (!isc.isA.String(start) && !isc.isA.Number(start))))) {
            return false;
        }

        if (this.upperBounds && end &&
            ((isNumber && isNaN(end)) ||
            (end && isDate && (!isc.isA.Date(end))) ||
            (end && isString && (!isc.isA.String(end) && !isc.isA.Number(end))))) {
            return false;
        }

        var undef;
        if (!nullMeansNull) {
            if (start === null || start === undef) {
                lowerBoundsCheck = false;
            }

            if (end === null || end === undef) {
                upperBoundsCheck = false;
            }

            if (isDate && !isc.isA.Date(start)) lowerBoundsCheck = false;
            if (isDate && !isc.isA.Date(end)) upperBoundsCheck = false;
        }

        isDate = isc.isA.Date(start) || isc.isA.Date(end);
        isNumber = isc.isA.Number(start) || isc.isA.Number(end);
        isString = isc.isA.String(start) || isc.isA.String(end);
        var ignoreCase = isString && this.caseInsensitive;

        if (fieldValue === null || fieldValue === undef) {
            if (isDate) {
                fieldValue = new Date(-8640000000000000);
            } else if (isNumber) {
                fieldValue = Number.MIN_VALUE;
            } else {
                fieldValue = "";
            }
        } else {
            if (isNumber && isNaN(fieldValue)) {
                start = "" + start;
                end = "" + end;
            }
            // So, we've been handed a Date object to test against a text data value. Whatever we might
            // try to do here will seem wrong to somebody. So, in the absence of anything more sensible,
            // we'll just return false (so all records are excluded when you have this kind of mismatch)
            if (isDate && !isc.isA.Date(fieldValue)) {
                return false;
            }
        }

        // >, >=, lower bounds check on between, betweenInclusive
        if (this.lowerBounds && lowerBoundsCheck) {
            if (dataSource.compareValues(start, fieldValue, fieldName, ignoreCase) <= (this.inclusive ? -1 : 0)) {
                return false;
            }
        }

        // <, <=, upper bounds check on between, betweenInclusive
        if (this.upperBounds && upperBoundsCheck) {
            if (dataSource.compareValues(end, fieldValue, fieldName, ignoreCase) >= (this.inclusive ? 1 : 0)) {
                return false;
            }
        }

        return true;
    }`
	
	stringComparison = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField) {
        if (isc.isA.Number(fieldValue)) {
            fieldValue = "" + fieldValue;
        }

        if (isc.isA.Boolean(fieldValue)) {
            isc.logWarn(
                "Attempt to compare a Boolean as String, testing value " + criterionValues.value +
                " with operator " + this.ID +
                ". This is an invalid comparison, so we are returning FALSE."
            );
            return false;
        }

        if (isc.isA.Date(fieldValue)) {
            isc.logWarn(
                "Attempt to compare a Date as String, testing value " + criterionValues.value +
                " with operator " + this.ID +
                ". This is an invalid comparison, so we are returning FALSE."
            );
            return false;
        }

        // Special-case code to match server-side exception when we get a request to do a string-
        // match on a non-text field (note that numbers are OK - they are converted above)
        if (fieldValue != null && !isc.isA.String(fieldValue)) {
            return true;
        }

        // - a null data value cannot contain anything, including null.
        // - a non-null data value is considered to contain null. We originally followed Javascript
        //   and considered non-null values to NOT contain null; however, it is not possible to implement
        //   this scheme in Hibernate without resorting to hackery.  It was easier to change the
        //   client-side rule
        if (fieldValue == null) {
            if (dataSource._strictMode) {
                if (dataSource.getField(fieldName).type == "number" || dataSource.getField(fieldName).type == "integer" ||
                    dataSource.getField(fieldName).type == "sequence" || dataSource.getField(fieldName).type == "float") {
                    if (criterionValues.value == null || isc.isA.Number(criterionValues.value) || isc.isA.Date(criterionValues.value)) {
                        return (this.negate ? !dataSource._withinLogicalNot : dataSource._withinLogicalNot);
                    } else {
                        return false;
                    }
                } else {
                    return (this.negate ? !dataSource._withinLogicalNot : dataSource._withinLogicalNot);
                }
            } else {
                return false;
            }
        }

        var test = criterionValues.value || "";

        if (isc.isA.Number(test)) {
            test = "" + test;
        }

        if (!isc.isA.String(test) || !isc.isA.String(fieldValue)) {
            return false;
        }

        if (this.caseInsensitive) {
            fieldValue = fieldValue.toLowerCase();
            test = test.toLowerCase();
        }

        var result = false;

        if (this.startsWith) {
            result = isc.startsWith(fieldValue, test);
        } else if (this.endsWith) {
            result = isc.endsWith(fieldValue, test);
        } else if (this.equals) {
            result = (fieldValue == test);
        } else {
            result = isc.contains(fieldValue, test);
        }

        return result;
    }`
	
	nullCheck = (fieldName, fieldValue, criterionValues, dataSource, isDateField) -> not fieldValue?
	
	regexpCheck = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField) {
        // Bail out early if value is undefined.  This is to provide cross-browser consistency,
        // because Moz always returns false for a test of RegExp(undefined), whereas all the
        // others (IE, Safari and Chrome tested) return true.  They all return false if the
        // value is null, so we'll mirror that and return false for undefined as well
        if (!criterionValues.value) {
            return false;
        }

        // Dates make no sense for regexp (numbers work OK)
        if (isc.isA.Date(criterionValues.value) || isc.isA.Date(fieldValue) ||
            isc.DateUtil.isRelativeDate(criterionValues.value)) {
            return false;
        }

        var regex;

        if (this.caseInsensitive) {
            regex = new RegExp(criterionValues.value, "i");
        } else {
            regex = new RegExp(criterionValues.value);
        }

        return regex.test(fieldValue);
    }`
	
	matchesPatternCheck = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField, isContains) {
        // If for some reason the user has set the patternEscapeChar to an empty or undefined
        // value, make sure we abort here.
        if (!dataSource.patternEscapeChar || dataSource.patternEscapeChar.length > 1) {
            throw "dataSource.patternEscapeChar cannot be null or undefined";
        }

        // Lets prep for the state machine. We need the wildcards in arrays to make it easier
        // and more readable below where we check if the character being looked at is a wildcard.
        var singleWildcards = isc.isA.Array(dataSource.patternSingleWildcard) ? dataSource.patternSingleWildcard : [dataSource.patternSingleWildcard || "?", "%"];
        var multiWildcards = isc.isA.Array(dataSource.patternMultiWildcard) ? dataSource.patternMultiWildcard : [dataSource.patternMultiWildcard || "*"];
        var escapeFound = false;
        var searchExpression = "";
        var value = criterionValues.value;

        // Small state machine to go through the value string, find escape characters as well
        // as wildcard characters and build a regular expression.
        for (var i = 0; i < value.length; i++) {
            // If the character matches the patternEscapeChar on the DataSource, set the engine
            // to ESCAPE state and continue with the next character.
            if (value[i] === dataSource.patternEscapeChar) {
                escapeFound = true;
                continue;
            }

            // If the previous character was an escape character then we need to make sure
            // that this character will treated as a string literal by the regex engine.
            if (escapeFound) {
                // We do this by checking if its a special regex character and if it is we
                // prefix it with the regex escape character.
                searchExpression += value[i].replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");

                // Go back to normal state now that the escape has been dealt with.
                escapeFound = false;
            } else {
                // We know that the previous character was not an escape character to lets
                // carry on.

                // If we've come across a multi wildcard, lets add regex .* and continue.
                if (multiWildcards.contains(value[i])) {
                    searchExpression += ".*";
                    continue;
                }

                // If we've come across a single wildcard, lets add regex . and continue.
                if (singleWildcards.contains(value[i])) {
                    searchExpression += ".";
                    continue;
                }

                searchExpression += value[i];
            }
        }

        if (isContains) {
            criterionValues.value = "^.*" + searchExpression + ".*$";
        } else {
            criterionValues.value = "^" + searchExpression + "$";
        }

        // Now lets pass this over to the regexpCheck method and let it do its thing.
        return regexpCheck.apply(this, [fieldName, fieldValue, criterionValues, dataSource, isDateField]);
    }`
	
	containsPatternCheck = (fieldName, fieldValue, criterionValues, dataSource, isDateField) ->
		matchesPatternCheck(fieldName, fieldValue, criterionValues, dataSource, isDateField, true)
	
	contains = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField) {
        // We don't support strict SQL mode for this operator - it raises too many hard problems
        // on the server side.
        var value = criterionValues.value || [];

        // Convert a non-null single value into an Array containing that value
        if (!isc.isAn.Array(value)) {
            value = [value];
        }

        if (isc.isA.Date(fieldValue)) {
            for (var i = 0; i < value.length; i++) {
                var isDate = isc.isA.Date(value[i]);

                // convert relative dates as necessary
                if (isDateField && !isDate && isc.DateUtil.isRelativeDate(value[i])) {
                    value[i] = isc.DateUtil.getAbsoluteDate(value[i]);
                }

                if (isc.isA.Date(value[i]) &&
                    dataSource.compareDates(value[i], fieldValue, fieldName) == 0) {
                    return true;
                }
            }
        } else {
            return value.contains(fieldValue);
        }
    }`
	
	fieldValueCheck = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField) {
        // Include all records if the "other" field name is null
        if (criterionValues.value == null) {
            return true;
        }

        // We do not support strict SQL mode for this operator, because different databases behave differently
        // if the two fields are of different types - we can't match a behavior that varies by database.
        var fieldsMatch = false;

        if (isc.isAn.Array(fieldValue) && isc.isAn.Array(criterionValues.otherValue)) {
            fieldsMatch = fieldValue.equals(criterionValues.otherValue);
        } else {
            fieldsMatch = (criterionValues.otherValue == fieldValue);
        }

        // Dates aren't equal in JS unless they are the same object, so we need a special compare
        if (isc.isA.Date(criterionValues.otherValue) && isc.isA.Date(fieldValue)) {
            fieldsMatch = (dataSource.compareDates(
                criterionValues.otherValue, fieldValue, fieldName,
                criterionValues.value
            ) == 0);
        }

        return fieldsMatch;
    }`
	
	fieldStringComparison = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField) {
        // Include all records if the "other" field name is null
        if (criterionValues.value == null) {
            return true;
        }

        criterionValues.value = criterionValues.otherValue;

        // Calling another operator condition, we need to use apply here in order to fool the scope.
        // This is because this.negate needs to be the correct one according to this operator.
        return stringComparison.apply(this, [fieldName, fieldValue, criterionValues, dataSource, isDateField]);
    }`
	
	fieldRangeCheck = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField) {
        // Include all records if the "other" field name is null
        if (criterionValues.value == null) {
            return true;
        }

        criterionValues.value = criterionValues.otherValue;

        // "tested" is the value of "otherField".  If it is null or undefined, the rangeCheck()
        // method is going to assume that means "no bounds".  That's OK for a straight
        // range check - if you specify "lessThan" and then provide no value to compare
        // against, it seems more likely that you meant "don't check" rather than
        // "exclude everything".  But in the case of a field comparison, the compare value
        // is different for every row, so it seems much more likely that you would want a
        // null value to be considered "low" - so in a "lessThanField" test, you would expect
        // a row to be excluded if the primary field was non-null and the otherField was null.
        // The final param to the rangeCheck() call switches off this "no bounds" behavior
        return rangeCheck.apply(this, [fieldName, fieldValue, criterionValues, dataSource, isDateField, true]);
    }`
	
	booleanOperator = `function (fieldName, fieldValue, criterionValues, dataSource, isDateField) {
        var criterion = criterionValues.criterion;
        var record = criterionValues.record;
        var returnVal;

        if (!criterion.criteria) {
            // This can legitimately happen if the user proceeds with an "empty" FilterBuilder
            // (ie, one they haven't set any values on).  FilterBuilder strips out all the
            // empty conditions and returns an empty array; something further downstream is
            // throwing that empty array away, so by the time we get here criteria is undef.
            // So we'll just set an undef criteria to the empty array and let it drop through
            criterion.criteria = [];
        }
        if (!isc.isAn.Array(criterion.criteria)) {
            isc.logWarn(
                "AdvancedCriteria: found boolean operator where subcriteria was not " +
                "an array.  Subcriteria was: " + isc.echoFull(criterion.criteria)
            );
            return false;
        }

        // Because we now need to match SQL null-handling behavior, we have to return false even
        // for negated clauses such as not(value equals null). Therefore, we can't just return false
        // if we find a null - we need to return false in the normal case, true where we're nested
        // inside a "not" clause, and then toggle back and forth between true and false as we progress
        // through multiple levels of nested "not" clauses.

        if (this.isNot) {
            dataSource._withinLogicalNot = !dataSource._withinLogicalNot;
        }

        for (var idx = 0; idx < criterion.criteria.length; idx++) {
            var bool = dataSource.evaluateCriterion(record, criterion.criteria[idx]);

            if (this.isAnd && !bool) {
                returnVal = false;
            }

            if (this.isNot && bool) {
                returnVal = false;
            }

            if (this.isOr && bool) {
                returnVal = true;
            }

            if (returnVal != null) {
                break;
            }
        }

        // If we get here and returnVal is undefined, "and" or "not" have succeeded, "or" has failed
        if (returnVal == null) {
            returnVal = !this.isOr;
        }

        // Put "within logical not" status back the way it was
        if (this.isNot) {
            dataSource._withinLogicalNot = !dataSource._withinLogicalNot;
        }

        return returnVal;
    }`
	
	booleanOperatorComp = `function (newCriterion, oldCriterion, operator, ds) {
        if (!oldCriterion.criteria) oldCriterion.criteria = [];
        if (!isc.isAn.Array(oldCriterion.criteria)) {
            isc.logWarn(
                "AdvancedCriteria: boolean compareCriteria found " +
                "where old subcriteria was not an array"
            );
            return -1;
        }
        if (!newCriterion.criteria) newCriterion.criteria = [];
        if (!isc.isAn.Array(newCriterion.criteria)) {
            isc.logWarn(
                "AdvancedCriteria: boolean compareCriteria found " +
                "where new subcriteria was not an array"
            );
            return -1;
        }
        var rtn,
            thisLevelRtn = 0,
            oldCount = oldCriterion.criteria.length,
            newCount = newCriterion.criteria.length;

        if (newCount > oldCount && operator.isOr) {
            // We can indicate less restrictive right now without having to check the
            // sub-criteria - there's an extra "or" condition
            return -1;
        }

        var oldWork = isc.clone(oldCriterion.criteria);
        var newWork = isc.clone(newCriterion.criteria);

        for (var i = 0; i < oldCount; i++) {
            var oldSubCriterion = oldWork[i];
            var newSubCriterion = i > newCount ? null : newWork[i];
            if (!newSubCriterion ||
                (newSubCriterion && newSubCriterion.fieldName != oldSubCriterion.fieldName ||
                newSubCriterion.operator != oldSubCriterion.operator ||
                newSubCriterion.processed == true)) {
                newSubCriterion = null;
                for (var j = 0; j < newCount; j++) {
                    if (newWork[j].processed) continue;
                    if (newWork[j].fieldName == oldSubCriterion.fieldName &&
                        newWork[j].operator == oldSubCriterion.operator) {
                        newSubCriterion = newWork[j];
                        break;
                    }
                }
            }

            if (newSubCriterion && oldSubCriterion) {
                newSubCriterion.processed = true;
                rtn = ds.compareAdvancedCriteria(newSubCriterion, oldSubCriterion);
            } else {
                if (oldSubCriterion && !newSubCriterion) {
                    // Fewer criteria
                    if (operator.isOr) rtn = 1;
                    if (operator.isAnd) rtn = -1;
                    if (operator.isNot) rtn = -1;
                }
            }
            if (operator.isAnd && rtn == -1) return -1;
            if (operator.isOr && rtn == -1) return -1;
            if (operator.isNot && rtn == 1) return -1;
            // If any sub-criterion compare comes back as 1 (-1 for NOT), then we should
            // return 1; if they are all 0 we should return 0.
            if (rtn != 0) thisLevelRtn = 1;
        }

        for (var i = 0; i < newCount; i++) {
            if (!newWork[i].processed) {
                // Either there are more new criteria than old, or we've found at least one
                // that could not be matched.
                if (operator.isOr) return -1;
                if (operator.isAnd) return 1;
                if (operator.isNot) return -1;
            }
        }

        // If we get here, we can indicate identical / more restrictive
        return thisLevelRtn;
    }`
	
	equalityComp = `function (newCriterion, oldCriterion, operator, ds) {
        // There's no way an equality check can be more restrictive - either it's identical,
        // or it's less restrictive
        if (newCriterion.fieldName == oldCriterion.fieldName) {
            var eq = ds.compareValues(
                    newCriterion.value, oldCriterion.value,
                    newCriterion.fieldName
                ) == 0;
            if (eq) {
                return 0;
            }
        }

        return -1;
    }`
	
	rangeCheckComp = `function (newCriterion, oldCriterion, operator, ds) {
        // We can return 1 as follows:
        // 1 greaterThan/greaterOrEqual. Return 1 if the new value is larger than the old one.
        // 2 lessThan/lessThanOrEqual.   Return 1 if the new value is smaller than the old one.
        // 3 between/betweenInclusive.   Return 1 if the new start value is larger than the old
        //                               start value but not larger than the old end value,
        //                               OR the new end value is smaller than the old end value
        //                               but not smaller than the old start value.
        var fieldName = newCriterion.fieldName;
        if (newCriterion.fieldName == oldCriterion.fieldName) {
            if (operator.upperBounds && operator.lowerBounds) {
                if (ds.compareValues(newCriterion.start, oldCriterion.start, fieldName) == 0) {
                    if (ds.compareValues(newCriterion.end, oldCriterion.end, fieldName) == 0) {
                        return 0;
                    }
                }
            } else {
                if (ds.compareValues(newCriterion.value, oldCriterion.value, fieldName) == 0) {
                    return 0;
                }
            }

            var newStart = newCriterion.start == null ? newCriterion.value : newCriterion.start,
                oldStart = oldCriterion.start == null ? oldCriterion.value : oldCriterion.start,
                newEnd = newCriterion.start == null ? newCriterion.value : newCriterion.end,
                oldEnd = oldCriterion.start == null ? oldCriterion.value : oldCriterion.end;

            var isDate,
                isnumber;

            var oldLowerBounds = true,
                oldUpperBounds = true,
                newLowerBounds = true,
                newUpperBounds = true;

            // See the IDoc in the rangeCheck() function for a discussion of why we're doing this
            if (oldStart == null) oldLowerBounds = false;
            if (oldEnd == null) oldUpperBounds = false;
            if (newStart == null) newLowerBounds = false;
            if (newEnd == null) newUpperBounds = false;

            if (operator.lowerBounds && !operator.upperBounds && !newLowerBounds && !oldLowerBounds) {
                return 0;
            }

            if (operator.lowerBounds && !operator.upperBounds) {
                if (newLowerBounds && !oldLowerBounds) {
                    return 1;
                }
                if (oldLowerBounds && !newLowerBounds) {
                    return -1;
                }
                var rslt = ds.compareValues(newStart, oldStart, fieldName);
                if (rslt == -1) {
                    return 1;
                } else if (rslt == 0) {
                    return 0;
                }
            }

            if (operator.upperBounds && !operator.lowerBounds && !newUpperBounds && !oldUpperBounds) {
                return 0;
            }

            if (operator.upperBounds && !operator.lowerBounds) {
                if (newUpperBounds && !oldUpperBounds) {
                    return 1;
                }
                if (oldUpperBounds && !newUpperBounds) {
                    return -1;
                }
                var rslt = ds.compareValues(newStart, oldStart, fieldName);
                if (rslt == 1) {
                    return 1;
                } else if (rslt == 0) {
                    return 0;
                }
            }

            if (operator.lowerBounds && operator.upperBounds) {
                // Technically, checking for >= and <= here is not sufficient to infer more
                // restriction; however, it IS enough to infer either more restriction or an
                // identical pair of filters, and since we won't get this far if the filters
                // are identical, it's safe to return 1.
                if (ds.compareValues(newStart, oldStart, fieldName) <= 0 &&
                    ds.compareValues(newStart, oldEnd, fieldName) >= 0 &&
                    ds.compareValues(newEnd, oldEnd, fieldName) >= 0 &&
                    ds.compareValues(newEnd, oldStart, fieldName) <= 0) {
                    return 1;
                }
                if ((newLowerBounds && !oldLowerBounds) ||
                    (newUpperBounds && !oldUpperBounds)) {
                    return 1;
                }
                if (!newLowerBounds && !oldLowerBounds && !newUpperBounds && !oldLowerBounds) {
                    return 0;
                }
            }
        }
        return -1;
    }`
	
	stringComparisonComp = `function (newCriterion, oldCriterion, operator) {
        // We can return 1 as  follows:
        // 1 startsWith. Return 1 if the new value startsWith the old value AND is longer.
        //               Obey the caseInsensitive flag.
        //               If negate == true, the test is reversed - ie, old value must
        //               startWith new value, and new value must be shorter.
        // 2 endsWith.   Return 1 if the new value endsWith the old value AND is longer.
        //               Obey the caseInsensitive flag.
        //               If negate == true, the test is reversed - ie, old value must
        //               endWith new value, and new value must be shorter.
        // 3 contains.   Return 1 if the old value is a proper substring of the new value (ie,
        //               new value both contains and is longer than old value). Obey the
        //               caseInsensitive flag. If negate == true, the new field must be a
        //               substring of the old one.
        // 4 equals.     Return 0 if the new value exactly matches the old one.  This
        //               comparison is actually only used when in case-insensitive mode;
        //               obviously, we simply compare for equality otherwise.

        var oldVal = oldCriterion.value;
        var newVal = newCriterion.value;

        // Convert numbers to strings - other than that, reject anything that isn't a string
        if (isc.isA.Number(oldVal)) oldVal = "" + oldVal;
        if (isc.isA.Number(newVal)) newVal = "" + newVal;

        if (!isc.isA.String(oldVal) || !isc.isA.String(newVal)) return -1;

        if (operator.caseInsensitive) {
            oldVal = oldVal.toLowerCase();
            newVal = newVal.toLowerCase();
        }

        if (newCriterion.fieldName == oldCriterion.fieldName
            && newCriterion.value == oldCriterion.value
            && !operator.equals) {
            return 0;
        }

        if (operator.equals) {
            return oldVal == newVal ? 0 : -1;
        }

        if (operator.startsWith && !operator.negate &&
            newVal.length > oldVal.length && isc.startsWith(newVal, oldVal)) {
            return 1;
        }

        if (operator.startsWith && operator.negate &&
            oldVal.length > newVal.length && isc.startsWith(oldVal, newVal)) {
            return 1;
        }

        if (operator.endsWith && !operator.negate &&
            newVal.length > oldVal.length && isc.endsWith(newVal, oldVal)) {
            return 1;
        }

        if (operator.endsWith && operator.negate &&
            oldVal.length > newVal.length && isc.endsWith(oldVal, newVal)) {
            return 1;
        }

        if (!operator.startsWith && !operator.endsWith && !operator.negate &&
            newVal.length > oldVal.length && isc.contains(newVal, oldVal)) {
            return 1;
        }

        if (!operator.startsWith && !operator.endsWith && operator.negate &&
            oldVal.length > newVal.length && isc.contains(oldVal, newVal)) {
            return 1;
        }

        return -1;
    }`
	
	nullCheckComp = `function (newCriterion, oldCriterion, operator) {
        if (newCriterion.fieldName == oldCriterion.fieldName) {
            return 0;
        }

        return -1;
    }`
	
	regexpCheckComp = `function (newCriterion, oldCriterion, operator) {
        // We can't know whether the new regexp is more or less restrictive - either they
        // match, or we indicate less restrictive
        if (newCriterion.value == oldCriterion.value &&
            newCriterion.fieldName == oldCriterion.fieldName) {
            return 0;
        }

        return -1;
    }`
	
	patternCheckComp = `function (newCriterion, oldCriterion, operator) {
        if (newCriterion.value == oldCriterion.value &&
            newCriterion.fieldName == oldCriterion.fieldName) {
            return 0;
        }
        // The only case when we can determine that pattern became less restrictive is when
        // user added non wildcard symbols to it.
        if (newCriterion.value.length > oldCriterion.value.length &&
            newCriterion.fieldName == oldCriterion.fieldName) {
            var newIndex = 0;
            var oldIndex = 0;
            var wildcardChar = "*";
            while (oldIndex < oldCriterion.value.length) {
                while (newIndex < newCriterion.value.length) {
                    if (newCriterion.value[newIndex] == oldCriterion.value[oldIndex]) {
                        newIndex++;
                        break;
                    }
                    if (newCriterion.value[newIndex] == wildcardChar) {
                        return -1;
                    }
                    newIndex++;
                }
                oldIndex++;
            }
            // pattern end part
            while (newIndex < newCriterion.value.length) {
                if (newCriterion.value[newIndex] == wildcardChar) {
                    return -1;
                }
                newIndex++;
            }
            return 1;
        }
        return -1;
    }`
	
	setMembershipComp = `function (newCriterion, oldCriterion, operator) {
        // We can return 1 if the new set is a proper subset of the old one
        // (if negate == true, the old set must be a proper subset of the new one)
        if (newCriterion.fieldName == oldCriterion.fieldName) {

            // We can only sensibly compare Arrays
            if (!isc.isAn.Array(oldCriterion.value) || !isc.isAn.Array(newCriterion.value)) {
                return -1;
            }

            if (newCriterion.value.equals(oldCriterion.value)) {
                return 0;
            }

            if (!operator.negate && oldCriterion.value.containsAll(newCriterion.value)) {
                return 1;
            }

            if (operator.negate && newCriterion.value.containsAll(oldCriterion.value)) {
                return 1;
            }
        }

        return -1;
    }`
	
	fieldValueCheckComp = `function (newCriterion, oldCriterion, operator) {
        // There's no way this check can be more restrictive - either it's the same
        // or it's different, and if it's different we have to go back to the server.
        if (newCriterion.value == oldCriterion.value &&
            newCriterion.fieldName == oldCriterion.fieldName) {
            return 0;
        }

        return -1;
    }`
	
	builtinOps = `[
        {
            ID             : "equals",
            titleProperty  : "equalsTitle",
            negate         : false,
            valueType      : "fieldType",
            condition      : equality,
            compareCriteria: equalityComp,
            symbol         : "==",
            wildCard       : "*",
            canNormalize   : true,
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};

                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },

        {
            ID             : "notEqual",
            titleProperty  : "notEqualTitle",
            negate         : true,
            valueType      : "fieldType",
            condition      : equality,
            compareCriteria: equalityComp,
            symbol         : "!",
            wildCard       : "*",
            canNormalize   : true,
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};

                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "greaterThan",
            titleProperty  : "greaterThanTitle",
            lowerBounds    : true,
            valueType      : "fieldType",
            condition      : rangeCheck,
            compareCriteria: rangeCheckComp,
            symbol         : ">",
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};

                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "lessThan",
            titleProperty  : "lessThanTitle",
            upperBounds    : true,
            valueType      : "fieldType",
            condition      : rangeCheck,
            compareCriteria: rangeCheckComp,
            symbol         : "<",
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};

                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "greaterOrEqual",
            titleProperty  : "greaterOrEqualTitle",
            lowerBounds    : true,
            inclusive      : true,
            valueType      : "fieldType",
            condition      : rangeCheck,
            compareCriteria: rangeCheckComp,
            symbol         : ">=",
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};

                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "lessOrEqual",
            titleProperty  : "lessOrEqualTitle",
            upperBounds    : true,
            inclusive      : true,
            valueType      : "fieldType",
            condition      : rangeCheck,
            compareCriteria: rangeCheckComp,
            symbol         : "<=",
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};

                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "between",
            titleProperty  : "betweenTitle",
            lowerBounds    : true,
            upperBounds    : true,
            hidden         : true,
            valueType      : "valueRange",
            condition      : rangeCheck,
            compareCriteria: rangeCheckComp,
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};
                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "iBetween",
            titleProperty  : "iBetweenTitle",
            lowerBounds    : true,
            upperBounds    : true,
            hidden         : true,
            valueType      : "valueRange",
            condition      : rangeCheck,
            caseInsensitive: true,
            compareCriteria: rangeCheckComp,
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};
                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "betweenInclusive",
            titleProperty  : "betweenInclusiveTitle",
            lowerBounds    : true,
            upperBounds    : true,
            valueType      : "valueRange",
            inclusive      : true,
            condition      : rangeCheck,
            compareCriteria: rangeCheckComp,
            symbol         : "...",
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};
                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "iBetweenInclusive",
            titleProperty  : "iBetweenInclusiveTitle",
            lowerBounds    : true,
            upperBounds    : true,
            valueType      : "valueRange",
            inclusive      : true,
            condition      : rangeCheck,
            compareCriteria: rangeCheckComp,
            symbol         : "...",
            caseInsensitive: true,
            getCriterion   : function (fieldName, item) {
                var result = {fieldName: fieldName, operator: this.ID};
                if (isc.isA.RelativeDateItem(item))
                    result.value = item.getRelativeDate() || item.getValue();
                else result.value = item.getValue();

                return result;
            }
        },
        {
            ID             : "iEquals",
            titleProperty  : "iEqualsTitle",
            equals         : true,
            caseInsensitive: true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "==",
            wildCard       : "*",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "iContains",
            titleProperty  : "iContainsTitle",
            caseInsensitive: true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "~",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "iStartsWith",
            titleProperty  : "iStartsWithTitle",
            startsWith     : true,
            caseInsensitive: true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "^",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "iEndsWith",
            titleProperty  : "iEndsWithTitle",
            endsWith       : true,
            caseInsensitive: true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "|",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "contains",
            titleProperty  : "containsTitle",
            hidden         : true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "~",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "startsWith",
            titleProperty  : "startsWithTitle",
            startsWith     : true,
            hidden         : false,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "^",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "endsWith",
            titleProperty  : "endsWithTitle",
            endsWith       : true,
            hidden         : false,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "|",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "iNotEqual",
            titleProperty  : "iNotEqualTitle",
            caseInsensitive: true,
            equals         : true,
            negate         : true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "!",
            wildCard       : "*",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "iNotContains",
            titleProperty  : "iNotContainsTitle",
            caseInsensitive: true,
            negate         : true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "!~",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "iNotStartsWith",
            titleProperty  : "iNotStartsWithTitle",
            startsWith     : true,
            caseInsensitive: true,
            negate         : true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "!^",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "iNotEndsWith",
            titleProperty  : "iNotEndsWithTitle",
            endsWith       : true,
            caseInsensitive: true,
            negate         : true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "!@",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "notContains",
            titleProperty  : "notContainsTitle",
            negate         : true,
            hidden         : true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "!~",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "notStartsWith",
            titleProperty  : "notStartsWithTitle",
            startsWith     : true,
            negate         : true,
            hidden         : true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "!^",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "notEndsWith",
            titleProperty  : "notEndsWithTitle",
            endsWith       : true,
            negate         : true,
            hidden         : true,
            valueType      : "fieldType",
            condition      : stringComparison,
            symbol         : "!@",
            canNormalize   : true,
            compareCriteria: stringComparisonComp
        },
        {
            ID             : "isNull",
            titleProperty  : "isNullTitle",
            valueType      : "none",
            condition      : nullCheck,
            symbol         : "#",
            compareCriteria: nullCheckComp
        },
        {
            ID             : "notNull",
            titleProperty  : "notNullTitle",
            negate         : true,
            valueType      : "none",
            condition      : nullCheck,
            symbol         : "!#",
            compareCriteria: nullCheckComp
        },
        {
            ID             : "regexp",
            titleProperty  : "regexpTitle",
            hidden         : true,
            valueType      : "custom",
            condition      : regexpCheck,
            symbol         : "/regex/",
            compareCriteria: regexpCheckComp
        },
        {
            ID             : "iregexp",
            titleProperty  : "iregexpTitle",
            hidden         : true,
            caseInsensitive: true,
            valueType      : "custom",
            condition      : regexpCheck,
            symbol         : "/regex/",
            compareCriteria: regexpCheckComp
        },
        {
            ID             : "matchesPattern",
            titleProperty  : "matchesPatternTitle",
            hidden         : true,
            valueType      : "custom",
            symbol         : "==i~",
            wildcard       : "*",
            condition      : matchesPatternCheck,
            compareCriteria: patternCheckComp
        },
        {
            ID             : "iMatchesPattern",
            titleProperty  : "iMatchesPatternTitle",
            hidden         : true,
            caseInsensitive: true,
            valueType      : "custom",
            symbol         : "==~",
            wildcard       : "*",
            condition      : matchesPatternCheck,
            compareCriteria: patternCheckComp
        },
        {
            ID             : "containsPattern",
            titleProperty  : "containsPatternTitle",
            hidden         : true,
            valueType      : "custom",
            symbol         : "=i~",
            wildcard       : "*",
            condition      : containsPatternCheck,
            compareCriteria: patternCheckComp
        },
        {
            ID             : "iContainsPattern",
            titleProperty  : "iContainsPatternTitle",
            hidden         : true,
            caseInsensitive: true,
            valueType      : "custom",
            symbol         : "=~",
            wildcard       : "*",
            condition      : containsPatternCheck,
            compareCriteria: patternCheckComp
        },
        {
            ID             : "inSet",
            titleProperty  : "inSetTitle",
            valueType      : "valueSet",
            condition      : contains,
            compareCriteria: setMembershipComp,
            symbol         : "=(",
            closingSymbol  : ")",
            valueSeparator : "|",
            processValue   : function (value, ds) {
                return value.split(this.valueSeparator);
            }
        },
        {
            ID             : "notInSet",
            titleProperty  : "notInSetTitle",
            negate         : true,
            valueType      : "valueSet",
            condition      : contains,
            compareCriteria: setMembershipComp,
            symbol         : "!=(",
            closingSymbol  : ")",
            valueSeparator : "|",
            processValue   : function (value, ds) {
                return value.split(this.valueSeparator);
            }
        },
        {
            ID             : "equalsField",
            titleProperty  : "equalsFieldTitle",
            valueType      : "fieldName",
            hidden         : true,
            condition      : fieldValueCheck,
            symbol         : "=.",
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp,
            processValue   : function (value, ds) {
                if (!ds) return value;

                var field = ds.getField(value);

                if (field) return value;

                field = ds.getFieldByTitle(value);

                if (field) return field.name;

                return null;
            }
        },
        {
            ID             : "notEqualField",
            titleProperty  : "notEqualFieldTitle",
            negate         : true,
            hidden         : true,
            valueType      : "fieldName",
            condition      : fieldValueCheck,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "iEqualsField",
            titleProperty  : "iEqualsFieldTitle",
            equals         : true,
            hidden         : true,
            caseInsensitive: true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "iNotEqualField",
            titleProperty  : "iNotEqualFieldTitle",
            equals         : true,
            hidden         : true,
            caseInsensitive: true,
            negate         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "greaterThanField",
            titleProperty  : "greaterThanFieldTitle",
            lowerBounds    : true,
            hidden         : true,
            valueType      : "fieldName",
            condition      : fieldRangeCheck,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "lessThanField",
            titleProperty  : "lessThanFieldTitle",
            upperBounds    : true,
            hidden         : true,
            valueType      : "fieldName",
            condition      : fieldRangeCheck,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "greaterOrEqualField",
            titleProperty  : "greaterOrEqualFieldTitle",
            lowerBounds    : true,
            inclusive      : true,
            hidden         : true,
            valueType      : "fieldName",
            condition      : fieldRangeCheck,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "lessOrEqualField",
            titleProperty  : "lessOrEqualFieldTitle",
            upperBounds    : true,
            inclusive      : true,
            hidden         : true,
            valueType      : "fieldName",
            condition      : fieldRangeCheck,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "containsField",
            titleProperty  : "containsFieldTitle",
            hidden         : true,
            valueType      : "fieldName",
            hidden         : true,
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "startsWithField",
            titleProperty  : "startsWithTitleField",
            startsWith     : true,
            hidden         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "endsWithField",
            titleProperty  : "endsWithTitleField",
            endsWith       : true,
            hidden         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "iContainsField",
            titleProperty  : "iContainsFieldTitle",
            hidden         : true,
            caseInsensitive: true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "iStartsWithField",
            titleProperty  : "iStartsWithTitleField",
            startsWith     : true,
            hidden         : true,
            caseInsensitive: true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "iEndsWithField",
            titleProperty  : "iEndsWithTitleField",
            endsWith       : true,
            hidden         : true,
            caseInsensitive: true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "notContainsField",
            titleProperty  : "notContainsFieldTitle",
            hidden         : true,
            negate         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "notStartsWithField",
            titleProperty  : "notStartsWithTitleField",
            startsWith     : true,
            hidden         : true,
            negate         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "notEndsWithField",
            titleProperty  : "notEndsWithTitleField",
            endsWith       : true,
            hidden         : true,
            negate         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "iNotContainsField",
            titleProperty  : "iNotContainsFieldTitle",
            hidden         : true,
            caseInsensitive: true,
            negate         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "iNotStartsWithField",
            titleProperty  : "iNotStartsWithTitleField",
            startsWith     : true,
            hidden         : true,
            caseInsensitive: true,
            negate         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "iNotEndsWithField",
            titleProperty  : "iNotEndsWithTitleField",
            endsWith       : true,
            hidden         : true,
            caseInsensitive: true,
            negate         : true,
            valueType      : "fieldName",
            condition      : fieldStringComparison,
            canNormalize   : true,
            compareCriteria: fieldValueCheckComp
        },
        {
            ID             : "and",
            titleProperty  : "andTitle",
            isAnd          : true,
            valueType      : "criteria",
            condition      : booleanOperator,
            symbol         : " and ",
            compareCriteria: booleanOperatorComp
        },
        {
            ID             : "not",
            titleProperty  : "notTitle",
            isNot          : true,
            valueType      : "criteria",
            condition      : booleanOperator,
            compareCriteria: booleanOperatorComp
        },
        {
            ID             : "or",
            titleProperty  : "orTitle",
            isOr           : true,
            valueType      : "criteria",
            condition      : booleanOperator,
            symbol         : " or ",
            compareCriteria: booleanOperatorComp
        }
    ]`
	
	for builtin in builtinOps
		isc.DataSourceSS.addSearchOperator builtin
	
	## Create default typeOperators
	isc.DataSourceSS.setTypeOperators null, ["and", "or", "not"]
	
	##these are in addition to the base operators
	isc.DataSourceSS.setTypeOperators "text",
	                                  [
		                                  "regexp", "iregexp", "contains", "startsWith",
		                                  "endsWith", "iEquals", "equals", "iNotEqual",
		                                  "iBetween", "iBetweenInclusive",
		                                  "iContains", "iStartsWith", "iEndsWith", "startsWith", "endsWith",
		                                  "notContains", "notStartsWith", "notEndsWith",
		                                  "iNotContains", "iNotStartsWith", "iNotEndsWith",
		                                  "containsField", "startsWithField", "endsWithField",
		                                  "iEqualsField", "iNotEqualField",
		                                  "iContainsField", "iStartsWithField", "iEndsWithField",
		                                  "notContainsField", "notStartsWithField", "notEndsWithField",
		                                  "iNotContainsField", "iNotStartsWithField", "iNotEndsWithField",
		                                  "matchesPattern", "iMatchesPattern", "containsPattern", "iContainsPattern"
	                                  ]
	
	isc.DataSourceSS.setTypeOperators "textArea",
	                                  [
		                                  "contains", "startsWith",
		                                  "endsWith", "iEquals", "equals", "iNotEqual",
		                                  "iContains", "iStartsWith", "iEndsWith", "startsWith", "endsWith",
		                                  "notContains", "notStartsWith", "notEndsWith",
		                                  "iNotContains", "iNotStartsWith", "iNotEndsWith"
	                                  ]
	
	###"iBetweenInclusive",###
	isc.DataSourceSS.setTypeOperators "integer",
	                                  ["iEquals", "greaterThan", "lessThan", "greaterOrEqual", "lessOrEqual"]
	
	isc.DataSourceSS.setTypeOperators "float",
	                                  ["iEquals", "greaterThan", "lessThan", "greaterOrEqual", "lessOrEqual"]
	
	isc.DataSourceSS.setTypeOperators "time",
	                                  ["iEquals", "greaterThan", "lessThan", "greaterOrEqual", "lessOrEqual"]
	
	isc.DataSourceSS.setTypeOperators "date",
	                                  ["iEquals", "greaterThan", "lessThan", "greaterOrEqual", "lessOrEqual"]

isc._initBuiltInOperatorsSS()

isc.getLookupFileds = (foreignFiled)->
	res = []
	
	for field, value of @fields
		if @fields[field].lookup? and @fields[field].foreignField is foreignFiled
			res.add @fields[field]
	res

isc.getForeignFields = ->
	res = []
	
	for field, value of @fields
		if @fields[field].foreignKey?
			res.add(@fields[field])
	
	res
