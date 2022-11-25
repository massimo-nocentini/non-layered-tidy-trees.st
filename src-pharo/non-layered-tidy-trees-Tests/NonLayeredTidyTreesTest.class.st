Class {
	#name : #NonLayeredTidyTreesTest,
	#superclass : #LibLuaAbstractTest,
	#category : #'non-layered-tidy-trees-Tests'
}

{ #category : #testing }
NonLayeredTidyTreesTest class >> isAbstract [

	^ false
]

{ #category : #tests }
NonLayeredTidyTreesTest >> bigtreeFileReference [

	^ './pharo-local/iceberg/massimo-nocentini/non-layered-tidy-trees.st/lua-test-data/big-tree.lua'
		  asFileReference
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayout [

	| table canvas |
	"2012-175 Aqua Zuro"
	self liblua withOpenedLibsStateDo: [ :state | 
		| c |
		self liblua luaL_loadstring: state string: '
		
		local tidy = require "non-layered-tidy-trees"
		
		local tree, itree = tidy.trees {
		
        addspacers = false,

        [1] = {w = 70, h = 30, c = {2, -3, 4, 8}},
        [2] = {w = 10, h = 50, c = {}},
        [-3] = {w = 10, h = 100, c = { 3 } },
        [3] = {w = 20, h = 30, c = {}},
        [4] = {w = 30, h = 30, c = {5, 7}},
        [5] = {w = 20, h = 50, c = {6}},
        [6] = {w = 40, h = 10, c = {}},
        [7] = {w = 20, h = 20, c = {}},
        [8] = {w = 30, h = 50, c = {9, 10}},
        [9] = {w = 30, h = 20, c = {}},
        [10] = {w = 10, h = 10, c = {}},

    }

    local r = tree[1]

    tidy.layout { 
		root = r,
		vertically = false,
		centeredxy = true,
	 }

    local result = tidy.dbindrec (itree)

	 tidy.free(r)
	
	 return result
	'.

		c := self liblua lua_pcall: state nargs: 0 nresults: 1.

		self assert: c equals: self liblua LUA_OK.

		table := self liblua read: -1 from: state.

		canvas := RSCanvas new
			          @ RSCanvasController;
			          yourself.

		table inspect.

		table keysAndValuesDo: [ :k :v | 
			| box label composite extent |
			extent := (v at: #w) @ (v at: #h).

			box := RSNote new
				       model: k;
				       withBorder;
				       cornerRadius: Float goldenRatio;
				       color: Color white;
				       extent: extent;
				       position: (v at: #x) @ (v at: #y);
				       yourself.

			k < 0 ifTrue: [ box border dashArray: { Float goldenRatio } ].

			label := RSLabel new
				         model: k;
				         useDefaultCodeFont;
				         fontSizeSilverRatio;
				         yourself.

			RSLocation new
				center;
				stick: label on: box.

			composite := RSComposite new
				             shapes: { 
						             box.
						             label };
				             yourself.

			canvas addShape: composite ].

		canvas open ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayout1 [

	| table canvas |
	"2012-175 Aqua Zuro"
	self liblua withOpenedLibsStateDo: [ :state | 
		| c |
		self liblua luaL_loadstring: state string: '
		
		local tidy = require "non-layered-tidy-trees"
		
		local tree, itree = tidy.trees {
		
["doC6dnl"] = { w = 84.09333333333333, h = 21, c = {}, },
["doC6eyv"] = { w = 328.0, h = 32.9, c = {}, },
["doCh0k5"] = { w = 185.94666666666663, h = 21, c = {}, },
["foCcmsslw7m"] = { w = 88.696, h = 25, c = {"doC6eyv","doCh0k5",}, },
["foCcmsslw7o"] = { w = 107.41600000000001, h = 25, c = {}, },
["foCcmsslw7p"] = { w = 97.70400000000001, h = 25, c = {}, },
["doC87sh"] = { w = 259.32, h = 21, c = {}, },
["doC87si"] = { w = 285.84000000000003, h = 21, c = {}, },
["doC87u6"] = { w = 87.88000000000001, h = 21, c = {}, },
["doC87ug"] = { w = 225.81333333333333, h = 21, c = {}, },
["doC87uv"] = { w = 186.0533333333333, h = 21, c = {}, },
["doC87vr"] = { w = 178.34666666666666, h = 21, c = {}, },
["foCcmsslw7q"] = { w = 161.56, h = 25, c = {}, },
["foCcmsslw7n"] = { w = 255.19200000000004, h = 25, c = {"doC87sh","doC87si","doC87u6","doC87ug","doC87uv","doC87vr","foCcmsslw7q",}, },
["foCcmssi4sv"] = { w = 337.8666666666666, h = 46, c = {"doC6dnl","foCcmsslw7m","foCcmsslw7o","foCcmsslw7p","foCcmsslw7n",}, },


    }

    local r = tree.foCcmssi4sv

    tidy.layout { 
		root = r,
		vertically = false,
		centeredxy = true,
	 }


    local result = tidy.dbindrec (itree)

	 tidy.free(r)
	
	 return result
	'.

		c := self liblua lua_pcall: state nargs: 0 nresults: 1.

		self assert: c equals: self liblua LUA_OK.

		table := self liblua read: -1 from: state.


		canvas := RSCanvas new
			          @ RSCanvasController;
			          yourself.

		table inspect.

		table keysAndValuesDo: [ :k :v | 
			| box label composite extent |
			extent := (v at: #w) @ (v at: #h).

			box := RSNote new
				       model: k;
				       withBorder;
				       cornerRadius: Float goldenRatio;
				       color: Color white;
				       extent: extent;
				       position: (v at: #x) @ (v at: #y);
				       yourself.

			"k < 0 ifTrue: [ box border dashArray: { Float goldenRatio } ]."

			label := RSLabel new
				         model: k;
				         useDefaultCodeFont;
				         fontSizeSilverRatio;
				         yourself.

			RSLocation new
				center;
				stick: label on: box.

			composite := RSComposite new
				             shapes: { 
						             box.
						             label };
				             yourself.

			canvas addShape: composite ].

		canvas open ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayout2 [

	| table canvas |
	"2012-175 Aqua Zuro"
	self timeLimit: 1 minute.

	self liblua withOpenedLibsStateDo: [ :state | 
		| loadtime layouttime readtime drawingtime dbindtime |
		self liblua assert: [ :ll | 
			ll luaL_dostring: state string: 'tidy = require "non-layered-tidy-trees"' ].

		loadtime := [ 
		            self liblua assert: [ :ll | 
			            ll
				            luaL_dostring: state
				            string: self bigtreeFileReference contents ].

		            self liblua assert: [ :ll | 
			            ll
				            luaL_dostring: state
				            string: 'tree, itree = tidy.trees (spec)' ] ]
			            timeToRun.

		self liblua luaL_dostring: state string: 'r = tree.foAcmssi2tj'.

		layouttime := [ 
		              self liblua assert: [ :ll | 
			              ll luaL_dostring: state string: '
    tidy.layout { 
		root = r,
		vertically = false,
		centeredxy = true,
	 }
' ] ] timeToRun.

		dbindtime := [ 
		             self liblua assert: [ :ll | 
			             ll luaL_loadstring: state string: '
    local result = tidy.positions (itree)
	 tidy.free(r)
	 return result
	' ].

		             self liblua assert: [ :ll | 
			             ll lua_pcall: state nargs: 0 nresults: 1 ] ] timeToRun.

		readtime := [ table := self liblua read: -1 from: state ] timeToRun.

		drawingtime := [ 
		               canvas := RSCanvas new
			                         @ RSCanvasController;
			                         yourself.

		               table keysAndValuesDo: [ :k :v | 
			               | box label composite extent |
			               extent := (v at: #w) @ (v at: #h).

			               box := RSBox new
				                      model: k;
				                      withBorder;
				                      "cornerRadius: Float goldenRatio;"color:
					                      Color white;
				                      extent: extent;
				                      position: (v at: #x) @ (v at: #y);
				                      yourself.

			               "k < 0 ifTrue: [ box border dashArray: { Float goldenRatio } ]."

			               label := RSLabel new
				                        model: k;
				                        useDefaultCodeFont;
				                        fontSizeSilverRatio;
				                        yourself.

			               RSLocation new
				               center;
				               stick: label on: box.

			               composite := RSComposite new
				                            shapes: { 
						                            box.
						                            label };
				                            yourself.

			               canvas addShape: composite ].

		               canvas exportToSVG ] timeToRun.


		Dictionary new
			at: #table put: table;
			at: #loadtime put: loadtime;
			at: #layouttime put: layouttime;
			at: #readtime put: readtime;
			at: #dbindtime put: dbindtime;
			at: #drawingtime put: drawingtime;
			inspect ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayout3 [

	self timeLimit: 1 minute.

	self liblua withOpenedLibsStateDo: [ :state | 
		| loadtime layouttime drawingtime dbindtime nodesCount externalAddress contents canvas |
		contents := self bigtreeFileReference contents.
		nodesCount := contents lines size - 2.

		externalAddress := ExternalAddress allocate: 8 * 4 * nodesCount.

		self liblua assert: [ :ll | 
			ll luaL_dostring: state string: 'tidy = require "non-layered-tidy-trees"' ].

		loadtime := [ 
		            self liblua assert: [ :ll | 
			            ll luaL_dostring: state string: contents ].

		            self liblua assert: [ :ll | 
			            ll
				            luaL_dostring: state
				            string: 'tree, itree = tidy.trees (spec)' ] ]
			            timeToRun.

		self liblua luaL_dostring: state string: 'r = tree.foAcmssi2tj'.

		layouttime := [ 
		              self liblua assert: [ :ll | 
			              ll
				              luaL_dostring: state
				              string:
				              'tidy.layout { root = r, vertically = false, centeredxy = true, }' ] ]
			              timeToRun.

		"(MessageSend receiver: #_ENV selector: #r)."
		self liblua
			push: (MessageSend
					 receiver: #tidy
					 selector: #flatcoordinatesinto
					 arguments: { 
							 #r.
							 externalAddress })
			on: state.

		dbindtime := [ 
		             self liblua assert: [ :ll | 
			             ll lua_pcall: state nargs: 2 nresults: 0 ].

		             self liblua assert: [ :ll | 
			             ll luaL_dostring: state string: 'tidy.free(r)' ] ] timeToRun.

		drawingtime := [ 
		               canvas := RSCanvas new
			                         @ RSCanvasController;
			                         yourself.

		               1 to: nodesCount do: [ :k | 
			               | kk box label composite extent x y w h |
			               kk := k - 1 * 32.

			               x := externalAddress float64AtOffset: kk.
			               y := externalAddress float64AtOffset: kk + 8.
			               w := externalAddress float64AtOffset: kk + 16.
			               h := externalAddress float64AtOffset: kk + 24.

			               extent := w @ h.

			               box := RSNote new
				                      withBorder;
				                      cornerRadius: Float goldenRatio;
				                      color: Color white;
				                      extent: extent;
				                      position: x @ y;
				                      yourself.

			               "k < 0 ifTrue: [ box border dashArray: { Float goldenRatio } ]."

			               "label := RSLabel new
				                        model: k;
				                        useDefaultCodeFont;
				                        fontSizeSilverRatio;
				                        yourself.

			               RSLocation new
				               center;
				               stick: label on: box.

			               composite := RSComposite new
				                            shapes: { 
						                            box.
						                            label };
				                            yourself."

			               canvas addShape: box ].

		               canvas open ] timeToRun.

		canvas exportToSVG.

		Dictionary new
			at: #loadtime put: loadtime;
			at: #layouttime put: layouttime;
			at: #dbindtime put: dbindtime;
			at: #drawingtime put: drawingtime;
			inspect.

		externalAddress free ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayout3_small [

	self timeLimit: 1 minute.

	self liblua withOpenedLibsStateDo: [ :state | 
		| c loadtime layouttime drawingtime dbindtime nodesCount externalAddress contents canvas |
		contents := './pharo-local/iceberg/massimo-nocentini/non-layered-tidy-trees.st/lua-test-data/small-tree.lua'
			            asFileReference contents.
		nodesCount := contents lines size - 2.

		externalAddress := ExternalAddress allocate: 8 * 4 * nodesCount.

		c := self liblua
			     luaL_dostring: state
			     string: 'tidy = require "non-layered-tidy-trees"'.

		self assert: c equals: 0.

		loadtime := [ 
		            c := self liblua luaL_dostring: state string: contents.
		            self assert: c equals: 0.

		            self liblua
			            luaL_dostring: state
			            string: 'tree, itree = tidy.trees (spec)' ] timeToRun.

		self liblua luaL_dostring: state string: 'r = tree.foCcmssi4sv'.

		layouttime := [ 
		              self liblua luaL_dostring: state string: '
    tidy.layout { 
		root = r,
		vertically = false,
		centeredxy = true,
	 }
' ] timeToRun.

		dbindtime := [ 
		             self liblua lua: state getglobal: 'tidy'.
		             self liblua
			             lua: state
			             get: -1
			             field: 'flatcoordinatesinto'.
		             self liblua lua: state getglobal: 'r'.
		             self liblua
			             lua_pushlightuserdata: state
			             pointer: externalAddress.

		             c := self liblua lua_pcall: state nargs: 2 nresults: 0. "self liblua read:-1 from: state."
		             self assert: c equals: 0.

		             self liblua lua_pop: state nelements: 1. "to remove the global `tidy` table."

		             self liblua luaL_dostring: state string: 'tidy.free(r)' ]
			             timeToRun.


		drawingtime := [ 
		               canvas := RSCanvas new
			                         @ RSCanvasController;
			                         yourself.


		               1 to: nodesCount do: [ :k | 
			               | kk box label composite extent x y w h |
			               kk := k - 1 * 32.

			               x := externalAddress float64AtOffset: kk.
			               y := externalAddress float64AtOffset: kk + 8.
			               w := externalAddress float64AtOffset: kk + 16.
			               h := externalAddress float64AtOffset: kk + 24.

			               extent := w @ h.

			               box := RSBox new
				                      withBorder;
				                      "cornerRadius: Float goldenRatio;"color:
					                      Color white;
				                      extent: extent;
				                      position: x @ y;
				                      yourself.

			               "k < 0 ifTrue: [ box border dashArray: { Float goldenRatio } ]."

			               label := RSLabel new
				                        model: k;
				                        useDefaultCodeFont;
				                        fontSizeSilverRatio;
				                        yourself.

			               RSLocation new
				               center;
				               stick: label on: box.

			               composite := RSComposite new
				                            shapes: { 
						                            box.
						                            label };
				                            yourself.

			               canvas addShape: composite ].

		               canvas exportToSVG ] timeToRun.


		Dictionary new
			at: #loadtime put: loadtime;
			at: #layouttime put: layouttime;
			at: #dbindtime put: dbindtime;
			at: #drawingtime put: drawingtime;
			inspect.

		externalAddress free.

		canvas open ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayoutIssue [

	| table canvas |
	"https://github.com/Klortho/d3-flextree/issues/1#issuecomment-369856820"
	self liblua withOpenedLibsStateDo: [ :state | 
		| c |
		self liblua luaL_loadstring: state string: '
		
		local tidy = require "non-layered-tidy-trees"
		
		local tree, itree = tidy.trees {
		
        addspacers = false,

        [0] = {w = 40, h = 40, c = {1, 2}},
        [1] = {w = 40, h = 40, c = {}},
        [2] = {w = 40, h = 40, c = { 3, 4 } },
        [3] = {w = 100, h = 40, c = {}},
        [4] = {w = 200, h = 40, c = {}},
    }

    local r = tree[0]

    tidy.layout { 
		root = r,
		vertically = true,
		centeredxy = true,
	 }

    local result = tidy.dbindrec (itree)

	 tidy.free(r)
	
	 return result
	'.

		c := self liblua lua_pcall: state nargs: 0 nresults: 1.

		self assert: c equals: 0.

		table := self liblua read: -1 from: state.

		canvas := RSCanvas new
			          @ RSCanvasController;
			          yourself.

		table inspect.

		table keysAndValuesDo: [ :k :v | 
			| box label composite extent |
			extent := (v at: #w) @ (v at: #h).

			box := RSNote new
				       model: k;
				       withBorder;
				       cornerRadius: Float goldenRatio;
				       color: Color white;
				       extent: extent;
				       position: (v at: #x) @ (v at: #y);
				       yourself.

			k < 0 ifTrue: [ box border dashArray: { Float goldenRatio } ].

			label := RSLabel new
				         model: k;
				         useDefaultCodeFont;
				         fontSizeSilverRatio;
				         yourself.

			RSLocation new
				center;
				stick: label on: box.

			composite := RSComposite new
				             shapes: { 
						             box.
						             label };
				             yourself.

			canvas addShape: composite ].

		canvas open ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayoutIssue1 [

	| table canvas |
	"https://github.com/Klortho/d3-flextree/issues/1#issuecomment-369856820"
	self liblua withOpenedLibsStateDo: [ :state | 
		| c |
		self liblua luaL_loadstring: state string: '
		
		local tidy = require "non-layered-tidy-trees"
		
		local tree, itree = tidy.trees {
		
        addspacers = false,

        [0] = {w = 40, h = 40, c = {1, 2}},
        [1] = {w = 40, h = 40, c = {}},
        [2] = {w = 40, h = 40, c = { 3 } },
        [3] = {w = 40, h = 40, c = { 4, 5 } },
        [4] = {w = 100, h = 40, c = {}},
        [5] = {w = 200, h = 40, c = {}},
    }

    local r = tree[0]

    tidy.layout { 
		root = r,
		vertically = true,
		centeredxy = true,
	 }

    local result = tidy.dbindrec (itree)

	 tidy.free(r)
	
	 return result
	'.

		c := self liblua lua_pcall: state nargs: 0 nresults: 1.

		self assert: c equals: 0.

		table := self liblua read: -1 from: state.

		canvas := RSCanvas new
			          @ RSCanvasController;
			          yourself.

		table inspect.

		table keysAndValuesDo: [ :k :v | 
			| box label composite extent |
			extent := (v at: #w) @ (v at: #h).

			box := RSNote new
				       model: k;
				       withBorder;
				       cornerRadius: Float goldenRatio;
				       color: Color white;
				       extent: extent;
				       position: (v at: #x) @ (v at: #y);
				       yourself.

			k < 0 ifTrue: [ box border dashArray: { Float goldenRatio } ].

			label := RSLabel new
				         model: k;
				         useDefaultCodeFont;
				         fontSizeSilverRatio;
				         yourself.

			RSLocation new
				center;
				stick: label on: box.

			composite := RSComposite new
				             shapes: { 
						             box.
						             label };
				             yourself.

			canvas addShape: composite ].

		canvas open ]
]
