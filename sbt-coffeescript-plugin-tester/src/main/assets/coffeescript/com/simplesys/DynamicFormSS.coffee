isc.defineClass("DynamicFormSS", isc.DynamicForm).addProperties
	"autoDraw": false
	"addField" : (field, pos) ->
		if isc.isA.Object(field) and field.name?
			fields = @fields.filter (_field)-> field.name isnt _field.name
			if isc.isA.Number pos
				fields.addAt field, pos
			else
				fields.add field
			@setFields fields

			return

	"saveData":  (callback, requestProperties) ->
		requestProperties = {} unless requestProperties
		requestProperties.data = {} unless requestProperties.data

		values = @getValues()
		@getFields().forEach ((item) -> if (item.value?) then values[item.name] = item.value; return)

		isc.addProperties requestProperties.data, values

		if @dataSource?.wildRecordJS?
			isc.addProperties requestProperties.data, @dataSource.wildRecordJS

		@Super "saveData", [callback, requestProperties]
		return

