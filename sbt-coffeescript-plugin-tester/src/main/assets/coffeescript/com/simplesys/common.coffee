Object.defineProperty String.prototype,
                      "isNotEmpty",
                      get: ->
	                      (@ and @.trim().length > 0)

Object.defineProperty String.prototype,
                      "isEmpty",
                      get: ->
	                      not @.isNotEmpty
