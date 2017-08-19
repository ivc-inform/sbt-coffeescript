isc.defineClass("OfflineSS", isc.Offline).addClassMethods
	"put": (key, value, recycleEntries) ->
		if not key?
			Log.logWarn("key: #{key}")
		else if not value?
			Log.logWarn("value: #{value}")
			isc.Offline.remove key
		else
			isc.Offline.put key, value, recycleEntries
		return

	"get": (key, defaultValue) ->
		res = isc.Offline.get key

		res or defaultValue

	"getFromBase": (key, defaultValue, _callback) ->
		ts = simpleSyS.timeStamp()
		isc.RPCManagerSS.sendRequest
			actionURL: "#{simpleSysContextPath}accessor/Fetch"
			data     :
				guid: key
				ts  : ts
			callback : (rpcResponse, data, rpcRequest) ->
				if isc.isA.Function(_callback) and data?.response?.data?.properties4Storage and isc.isA.String(data.response.data.properties4Storage)
					@.fireCallback _callback, "result", [if data.response.data.properties4Storage is strEmpty then [] else isc.JSON.decode(data.response.data.properties4Storage)]
					return
		return

	"getBoolean": (key, defaultValue) ->
		res = isc.Offline.get key

		if isc.isA.String(res) is false
			return false

		res = res.bool

		if isc.isA.Boolean(defaultValue) is true
			res or defaultValue
		else
			res or false

	"putToBase": (key, value, callback) ->
		isc.RPCManagerSS.sendRequest
			actionURL: "#{simpleSysContextPath}accessor/Update"
			data     :
				guid: key
				json: value
				callback: callback
		return

	"getNumber": (key, defaultValue) ->
		res = Number isc.Offline.get key

		if isc.isA.Number(defaultValue) is true
			res or defaultValue
		else
			res

	"putBoolean": (key, value, recycleEntries) ->
		if isc.isA.Boolean(value) is true
			isc.Offline.put key, value, recycleEntries
		else if isc.isA.String(value) is true
			isc.Offline.put key, value.bool, recycleEntries
		else
			isc.Offline.put key, false, recycleEntries
		return

	"putNumber": (key, value, recycleEntries) ->
		isc.Offline.put key, Number(value), recycleEntries
		return

	"putArray": (key, values, recycleEntries) ->
		if not isc.isA.Array(values)
			values = [values]

		@removeArray key
		index = 0

		for value in values
			isc.OfflineSS.put key + index.toString(), value, recycleEntries
			index++
		return

	"getArray": (key) ->
		res = []
		index = 0

		_res = isc.OfflineSS.get key + index.toString()
		res.add _res

		while _res
			index++
			_res = isc.OfflineSS.get key + index.toString()

			if _res?
				res.add _res
		res

	"removeArray": (key) ->
		index = 0

		_res = isc.OfflineSS.get key + index.toString()
		while _res
			index++
			_key = key + index.toString()
			_res = isc.OfflineSS.get _key

			if _res?
				isc.OfflineSS.remove _key

		return
