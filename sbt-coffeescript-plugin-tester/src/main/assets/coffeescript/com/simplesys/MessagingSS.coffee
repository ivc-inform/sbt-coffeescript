if not isc.module_RealtimeMessaging?
	isc.module_RealtimeMessaging = 1
	isc.defineClass("MessagingSS").addClassProperties
		fireCallback            : isc.Class.fireCallback
		_maxRecentIDLength      : 20
		_subscribeReconnectDelay: 100
		eventStream             : ->
			res = not not window.EventSource
			if not res? then isc.error "Ваш браузер не поддерживает технологию SSE, что делает невозможным автоматическое получение сообщений от сервера. (Данная задача находится в доработке.)"
			res
		_channels               : {}
		_recentIDList           : []
		_handleEventSourceError : (e) -> undefined
		getSubscribedChannels   : -> isc.getKeys(@_channels)
		subscribe               : (channels, callback, subscribeCallback, target, event) ->
			if channels?
				if isc.isA.Function(subscribeCallback) is false and isc.isA.Object(subscribeCallback) is true and not target?
					target = subscribeCallback

				if isc.isA.Array(channels) is false
					channels = [channels]

				executed = false

				channels.forEach (channel) =>
					@_channels[channel] =
							isChannel: true
							target   : target
							callback : callback
							event : event

					executed = true
					return

				if executed is true
					@_reconnect event
					if subscribeCallback?
						isc.MessagingSS.fireCallback(subscribeCallback)
			return

		unsubscribe: (channels, unSubscribeCallback, event) ->
			if channels?
				if isc.isA.Array(channels) is false
					channels = [channels]

				channels.forEach (channel) =>
					if @_channels[channel]?
						delete @_channels[channel]
					return

				if isc.isA.emptyObject(@_channels) is true
					@disconnect event

				if unSubscribeCallback?
					isc.MessagingSS.fireCallback(unSubscribeCallback)
			return

		connected: ->
			isc.getKeys(@._channels?).length > 0

		_event: "message"

		_cleanup : (event) ->
			if not event?
				event = @_event

			if @_es?
				@_es.removeEventListener event, @_message, false

				@_es.close()
				delete @_es
			return

		disconnect: (event)-> @_cleanup(event); return

		_reconnect: (event) ->
			if isc.Page.isLoaded() isnt true
				if not @_setLoadEventHandler?
					_reconnect = -> isc.MessagingSS._reconnect callback

					isc.Page.setEvent("load", _reconnect)
					@_setLoadEventHandler = true

			if not @_subscribeReconnectTimer?
				_connect = -> isc.MessagingSS._connect(event);return
				@_subscribeReconnectTimer =
					isc.Timer.setTimeout(
						                    _connect,
						                    @_subscribeReconnectDelay,
						                    isc.Timer.MSEC
					                    )
			return

			
		checkSimpleSysContextPath: () ->
			if not @simpleSysContextPath? and not simpleSyS.simpleSysContextPath?
				Log.logError "simpleSysContextPath undefined"
				return
				
		messagingSubscribeURL: ->
			@checkSimpleSysContextPath()
			"#{if @simpleSysContextPath? then @simpleSysContextPath else simpleSyS.simpleSysContextPath}Message/Subscribe"
			
		messagingSendURL : ->
			@checkSimpleSysContextPath()
			"#{if @simpleSysContextPath? then @simpleSysContextPath else simpleSyS.simpleSysContextPath}Message/Send"

		_connect: (event) ->
			if not event?
				event = @_event

			isc.Timer.clear @_subscribeReconnectTimer
			@_subscribeReconnectTimer = null

			@_cleanup()

			_url = @messagingSubscribeURL()
			
			json = isc.JSONSS.encode(@_channels)
			###console.log "json (cs): #{json}"###
			
			uriBuilder = isc.URIBuilder.create isc.Page.getURL _url					    			
			uriBuilder.setQueryParam "subscribedChannels", json
			uriBuilder.setQueryParam "eventStream", "true"

			if uriBuilder.uri.length > 2000
				Log.logWarn "URI: #{uriBuilder.uri}"
				Log.logWarn "URI, БОЛЕЕ 2000 символов, это может быть опвсно"
				###return###

			###todo В случае необходимости подключения большого кол-ва каналов, необходимо разбиение их на несколько EventSource###

			###console.log "uriBuilder.uri (cs): #{uriBuilder.uri}"###
			@_es = new EventSource uriBuilder.uri

			@_es.onerror = @_handleEventSourceError

			###@_es.addEventListener event, @_message, false###
			@_es.addEventListener event, @_message
			return

		_message: (message) ->
			data = isc.JSONSS.decode message.data
			channels = data.channels

			if isc.isA.Array(channels) is false
				channels = [channels]

			id = message.lastEventId

			if id? and id isnt strEmpty
				if isc.MessagingSS._recentIDList.contains(id) is true
					return undefined

				isc.MessagingSS._recentIDList.push id
				if isc.MessagingSS._recentIDList.length > isc.MessagingSS._maxRecentIDLength
					isc.MessagingSS._recentIDList.shift()

			channels.forEach (channel) =>
				if isc.MessagingSS._channels[channel]?
					channel = isc.MessagingSS._channels[channel]
					callback = channel.callback
					if callback?
						isc.MessagingSS.fireCallback callback, "data", [data], channel
			return

		send: (channels, data, callback) ->
			if isc.isA.Array(channels) is false
				channels = [channels]

			isc.RPCManagerSS.sendRequest
				 actionURL: @messagingSendURL()
				 data     :
					 data    : data
					 channels: channels
				 callback : callback
			return
else
	if isc.isA.Function(isc?.Log?.logError) is true
		isc.Log.logError "Duplicate load of module 'RealtimeMessaging'."
