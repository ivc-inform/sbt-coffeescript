isc.defineClass("ChainMasterDetail", isc.LayoutSS).addProperties
	vertical: false
	"setFuncMenu": (funcMenu) ->
		@funcMenu = funcMenu
		return
	destroy : ->
		###@setViewState()###
		@Super "destroy", arguments
		return

	setViewState: ->
		@members.forEach (member) =>
			if @vertical is false
				id = "#{@getIdentifier()}.#{member.getIdentifier()}_width"
				###console.log "#{id}: #{member.getWidth()}"###
				isc.OfflineSS.putNumber id, member.getWidth()
			else
				id = "#{@getIdentifier()}.#{member.getIdentifier()}_height"
				###console.log "#{id}: #{member.getHeight()}"###
				isc.OfflineSS.putNumber id, member.getHeight()
			return
		@

	getViewState: ->
		i = 1
		@members.forEach (member) =>
			if (@vertical is false)
				if @members.length is i
					member.setWidth "*"
				else
					id = "#{@getIdentifier()}.#{member.getIdentifier()}_width"
					width = isc.OfflineSS.getNumber id, member.getWidth()
					###console.log "#{id}: #{width}"###
					member.setWidth width
			else
				if @members.length is i
					member.setHeight "*"
				else
					id = "#{@getIdentifier()}.#{member.getIdentifier()}_height"
					height = isc.OfflineSS.getNumber id, member.getWidth()
					###console.log "#{id}: #{height}"###
					member.setHeight id, height
			i++
			return
		@

	"initWidget": ->
		@Super "initWidget", arguments

		i = 1
		@members.forEach (member) =>
			member.number = i
			member.resized = =>
				if @isDrawn()
					@setViewState()
				return

			i++

		return
