isc.addMethods isc.isA,
               {
	               notEmptyArray: (object) -> isc.isAn.Array(object) && object.length isnt 0
               }