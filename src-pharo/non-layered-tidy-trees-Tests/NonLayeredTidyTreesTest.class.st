Class {
	#name : #NonLayeredTidyTreesTest,
	#superclass : #LibLuaAbstractTest,
	#traits : 'TIceImagesExporting',
	#classTraits : 'TIceImagesExporting classTrait',
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
NonLayeredTidyTreesTest >> highlightEmptyAreasLuaChunk: aChunk aCanvas: aCanvas highlightEmptyAreas: showHighlightShapes [

	self liblua withOpenedLibsStateDo: [ :state | 
		| table contourPairs shapes |
		self liblua assert: [ :ll | ll luaL_dostring: state chunk: aChunk ].

		table := self liblua
			         lua_getglobal: state name: 'result';
			         on: state at: -1.

		contourPairs := self liblua
			                lua_getglobal: state name: 'contourpairs';
			                on: state at: -1.

		self liblua lua_pop: state nelements: 2.

		shapes := Dictionary new.

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

			label := RSLabel new
				         model: (v at: #external_key) "-> (v at: #idx)";
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

			shapes at: k put: composite.

			aCanvas addShape: composite ].

		contourPairs := contourPairs collect: [ :aPair | 
			                | sr cl first_t second_t bottom tooClose |
			                sr := shapes at: aPair first.
			                cl := shapes at: aPair second.

			                first_t := table at: aPair first.
			                second_t := table at: aPair second.

			                tooClose := (first_t at: #y)
			                            + (first_t at: #h) halved closeTo:
				                            (second_t at: #y)
				                            - (second_t at: #h) halved.

			                tooClose ifFalse: [ 
				                | rect s right |
				                self liblua assert: [ :ll | 
					                | chunk |
					                chunk := 'bottom = tidy.maxbottombetween (tree.{1}, tree.{2}, false)' 
						                         format: { 
								                         aPair first.
								                         aPair second }.

					                ll luaL_dostring: state chunk: chunk ].

				                bottom := self liblua
					                          lua_getglobal: state name: 'bottom';
					                          on: state at: -1.
				                self liblua lua_pop: state nelements: 1.

				                right := (second_t at: #x)
				                         + (second_t at: #w) halved min:
					                         (first_t at: #x)
					                         + (first_t at: #w) halved.

				                rect := Rectangle
					                        left: bottom
					                        right: right
					                        top:
					                        (first_t at: #y)
					                        + (first_t at: #h) halved
					                        bottom:
					                        (second_t at: #y)
					                        - (second_t at: #h) halved.

				                s := RSNote new
					                     draggable;
					                     withBorder;
					                     cornerRadius: Float goldenRatio;
					                     color: Color red translucent;
					                     extent: rect extent;
					                     position: rect center;
					                     yourself.

				                showHighlightShapes ifTrue: [ aCanvas addShape: s ] ].

			                { 
				                aPair first. "-> first_t"
				                aPair second. "-> second_t"
				                bottom } ].

		contourPairs inspect.

		self liblua assert: [ :ll | 
			ll luaL_dostring: state chunk: 'tidy.free(r)' ] ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> paperTree: chunk onCanvas: aCanvas [

	self liblua withOpenedLibsStateDo: [ :state | 
		| table |
		self liblua assert: [ :ll | ll luaL_loadstring: state chunk: chunk ].

		self liblua assert: [ :ll | 
			ll lua_pcall: state nargs: 0 nresults: 1 ].

		table := self liblua on: state at: -1.

		table keysAndValuesDo: [ :k :v | 
			| box label composite |
			box := RSNote new
				       model: k;
				       withBorder;
				       cornerRadius: Float goldenRatio;
				       color: Color white;
				       extent: (v at: #w) @ (v at: #h);
				       position: (v at: #x) @ (v at: #y);
				       yourself.

			k < 0 ifTrue: [ box border dashArray: { Float goldenRatio } ].

			label := RSLabel new
				         model: (v at: #externalkey);
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

			aCanvas addShape: composite ].
"
		aCanvas open" ]
]

{ #category : #'export compiled methods' }
NonLayeredTidyTreesTest >> testExportCompiledMethods [

	self
		exportCompiledMethod:
			NonLayeredTidyTreesTest >> #testTreeLayoutPaperTreeFlatMemoryChunk;
		exportCompiledMethod:
			NonLayeredTidyTreesTest >> #vanDerPloegPaperTreeVertical
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayout2 [

	| table canvas |
	"2012-175 Aqua Zuro"
	self timeLimit: 1 minute.

	self liblua withOpenedLibsStateDo: [ :state | 
		| loadtime layouttime readtime drawingtime dbindtime |
		self liblua assert: [ :ll | 
			ll
				luaL_dostring: state
				chunk: 'tidy = require "non-layered-tidy-trees"' ].

		loadtime := [ 
		            self liblua assert: [ :ll | 
			            ll
				            luaL_dostring: state
				            chunk: self bigtreeFileReference contents ].

		            self liblua assert: [ :ll | 
			            ll
				            luaL_dostring: state
				            chunk: 'tree, itree = tidy.trees (spec)' ] ]
			            timeToRun.

		self liblua luaL_dostring: state chunk: 'r = tree.foAcmssi2tj'.

		layouttime := [ 
		              self liblua assert: [ :ll | 
			              ll luaL_dostring: state chunk: '
    tidy.layout { 
		root = r,
		vertically = false,
		centeredxy = true,
	 }
' ] ] timeToRun.

		dbindtime := [ 
		             self liblua assert: [ :ll | 
			             ll luaL_loadstring: state chunk: '
    local result = tidy.positions (itree)
	 tidy.free(r)
	 return result
	' ].

		             self liblua assert: [ :ll | 
			             ll lua_pcall: state nargs: 0 nresults: 1 ] ] timeToRun.

		readtime := [ table := self liblua on: state at: -1 ] timeToRun.

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
			ll
				luaL_dostring: state
				chunk: 'tidy = require "non-layered-tidy-trees"' ].

		loadtime := [ 
		            self liblua assert: [ :ll | 
			            ll luaL_dostring: state chunk: contents ].

		            self liblua assert: [ :ll | 
			            ll
				            luaL_dostring: state
				            chunk: 'tree, itree = tidy.trees (spec)' ] ]
			            timeToRun.

		self liblua luaL_dostring: state chunk: 'r = tree.foAcmssi2tj'.

		layouttime := [ 
		              self liblua assert: [ :ll | 
			              ll
				              luaL_dostring: state
				              chunk:
				              'tidy.layout { root = r, vertically = false, centeredxy = true, }' ] ]
			              timeToRun.

		"(MessageSend receiver: #_ENV selector: #r)."
		self liblua on: state push: (MessageSend
				 receiver: #tidy
				 selector: #flatcoordinatesinto
				 arguments: { 
						 #r.
						 externalAddress }).

		dbindtime := [ 
		             self liblua assert: [ :ll | 
			             ll lua_pcall: state nargs: 2 nresults: 0 ].

		             self liblua assert: [ :ll | 
			             ll luaL_dostring: state chunk: 'tidy.free(r)' ] ]
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
		| c loadtime layouttime drawingtime dbindtime nodesCount externalAddress contents canvas pairs |
		contents := './pharo-local/iceberg/massimo-nocentini/non-layered-tidy-trees.st/lua-test-data/small-tree.lua'
			            asFileReference contents.
		nodesCount := contents lines size - 2.

		externalAddress := ExternalAddress allocate: 8 * 4 * nodesCount.

		c := self liblua
			     luaL_dostring: state
			     chunk: 'tidy = require "non-layered-tidy-trees"'.

		self assert: c equals: 0.

		loadtime := [ 
		            c := self liblua luaL_dostring: state chunk: contents.
		            self assert: c equals: 0.

		            self liblua
			            luaL_dostring: state
			            chunk: 'tree, itree = tidy.trees (spec)' ] timeToRun.

		self liblua luaL_dostring: state chunk: 'r = tree.foCcmssi4sv'.

		pairs := OrderedCollection new.

		self liblua
			lua_register: state
			name: 'contourpairscb'
			cfunction: (self liblua fficallbackOnBlock: [ :s | 
					 | sr cl dist |
					 sr := self liblua lua_touserdata: s at: -3.
					 cl := self liblua lua_touserdata: s at: -2.
					 dist := self liblua lua_tonumber: s at: -1.
					 pairs
						 add: sr;
						 add: cl ]).

		layouttime := [ 
		              self liblua luaL_dostring: state chunk: '
    tidy.layout { 
		root = r,
		vertically = false,
		centeredxy = true,
		contourpairscb = contourpairscb,
	 }
' ] timeToRun.


		dbindtime := [ 
		             self liblua lua_getglobal: state name: 'tidy'.
		             self liblua
			             lua_getfield: state
			             at: -1
			             name: 'flatcoordinatesinto'.
		             self liblua lua_getglobal: state name: 'r'.
		             self liblua
			             lua_pushlightuserdata: state
			             externalAddress: externalAddress.

		             c := self liblua lua_pcall: state nargs: 2 nresults: 0. "self liblua read:-1 from: state."
		             self assert: c equals: 0.

		             self liblua lua_pop: state nelements: 1. "to remove the global `tidy` table."

		             self liblua luaL_dostring: state chunk: 'tidy.free(r)' ]
			             timeToRun.


		drawingtime := [ 
		               | shapeDictionary |
		               shapeDictionary := Dictionary new.

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
NonLayeredTidyTreesTest >> testTreeLayoutHighlightEmptyAreas [

	| spec |
	spec := '
		
		tidy = require "non-layered-tidy-trees"
		
		-- global variables
		tree, itree = tidy.trees {
		
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

 	 r = tree.foCcmssi4sv
	 contourpairs = { }

    tidy.layout { 
		root = r,
		vertically = false,
		centeredxy = true,
		contourpairscb = function (sr, cl, dist) 
			table.insert (contourpairs, { itree[sr], itree[cl], })			
		end,
	 }

    result = tidy.dbindrec (itree, "external_key")
'.

	self export: spec pathSuffix: 'clean' onCanvasDo: [ :aCanvas :luaChunk | 
		self
			highlightEmptyAreasLuaChunk: luaChunk
			aCanvas: aCanvas
			highlightEmptyAreas: false ].

	self export: spec pathSuffix: '' onCanvasDo: [ :aCanvas :luaChunk | 
		self
			highlightEmptyAreasLuaChunk: luaChunk
			aCanvas: aCanvas
			highlightEmptyAreas: true ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayoutIssue [

	self
		export: '
		
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
	'
		pathSuffix: ''
		onCanvasDo: [ :canvas :chunk | 
			| table |
			"https://github.com/Klortho/d3-flextree/issues/1#issuecomment-369856820"
			self liblua withOpenedLibsStateDo: [ :state | 
				self liblua assert: [ 
					self liblua luaL_loadstring: state chunk: chunk ].

				self liblua assert: [ :ll | 
					ll lua_pcall: state nargs: 0 nresults: 1 ].

				table := self liblua on: state at: -1.

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

					canvas addShape: composite ] ] ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayoutIssue1 [

	self
		export: '
		
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
	'
		pathSuffix: ''
		onCanvasDo: [ :canvas :chunk | 
			| table |
			"https://github.com/Klortho/d3-flextree/issues/1#issuecomment-369856820"
			self liblua withOpenedLibsStateDo: [ :state | 
				self liblua assert: [ :ll | 
					ll luaL_loadstring: state chunk: chunk ].

				self liblua assert: [ :ll | 
					ll lua_pcall: state nargs: 0 nresults: 1 ].

				table := self liblua on: state at: -1.

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

					canvas addShape: composite ] ] ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayoutPaperTree [

	self
		export: self vanDerPloegPaperTreeVertical
		pathSuffix: 'vertical'
		onCanvasDo: [ :aCanvas :luaChunk | 
		self paperTree: luaChunk onCanvas: aCanvas ].

	self
		export: (self vanDerPloegPaperTreeVertical
				 copyReplaceAll: 'vertically = true'
				 with: 'vertically = false')
		pathSuffix: 'horizontal'
		onCanvasDo: [ :aCanvas :luaChunk | 
		self paperTree: luaChunk onCanvas: aCanvas ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayoutPaperTreeFlatMemoryChunk [

	self liblua withOpenedLibsStateDo: [ :state | 
		| tbl whxyExternalAddress childrenExternalAddress n j doubleByteSize longByteSize extents addr |
		doubleByteSize := ExternalType double byteSize.
		longByteSize := ExternalType long byteSize.

		self liblua assert: [ :ll | 
			ll
				luaL_dostring: state
				chunk: 'tidy = require "non-layered-tidy-trees"' ].

		self liblua assert: [ :ll | 
			ll luaL_dostring: state chunk: '
	spec = {
	
        [1] = {w = 70, h = 30, c = {2, 3, 4, 8}},
        [2] = {w = 10, h = 50, c = {}},
        [3] = {w = 20, h = 30, c = {}},
        [4] = {w = 30, h = 30, c = {5, 7}},
        [5] = {w = 20, h = 50, c = {6}},
        [6] = {w = 40, h = 10, c = {}},
        [7] = {w = 20, h = 20, c = {}},
        [8] = {w = 30, h = 50, c = {9, 10}},
        [9] = {w = 30, h = 20, c = {}},
        [10] = {w = 10, h = 10, c = {}},

	}' ].

		tbl := self liblua
			       lua_getglobal: state name: 'spec';
			       on: state at: -1.

		n := tbl size.

		whxyExternalAddress := ExternalAddress allocate:
			                       doubleByteSize * n * 2.

		childrenExternalAddress := ExternalAddress allocate:
			                           longByteSize * (n + 9).

		extents := OrderedCollection new.
		j := n.
		tbl withIndexDo: [ :node :i | 
			| offset children |
			offset := i - 1.

			children := node at: #c.

			extents add: (node at: #w) @ (node at: #h).

			whxyExternalAddress
				float64AtOffset: offset * doubleByteSize put: (node at: #w);
				float64AtOffset: n + offset * doubleByteSize put: (node at: #h).

			childrenExternalAddress
				int32AtOffset: offset * longByteSize
				put: children size.

			children do: [ :child | 
				childrenExternalAddress int32AtOffset: j * longByteSize put: child.
				j := j + 1 ] ].

		self assert: j equals: n + 9.

		self liblua
			lua_getglobal: state name: 'tidy';
			lua_getfield: state at: -1 name: 'reifyflatchunks';
			lua_remove: state at: -2;
			lua_pushinteger: state value: n;
			lua_pushlightuserdata: state externalAddress: whxyExternalAddress;
			lua_pushlightuserdata: state
			externalAddress: childrenExternalAddress;
			lua_pushinteger: state value: 1.

		self liblua assert: [ :ll | 
			ll lua_pcall: state nargs: 4 nresults: 2 ].

		self liblua
			lua_setglobal: state name: 'nodes';
			lua_setglobal: state name: 'r'.

		self liblua
			lua_getglobal: state name: 'tidy';
			lua_getfield: state at: -1 name: 'layout';
			lua_remove: state at: -2;
			lua_newtable: state;
			lua_getglobal: state name: 'r';
			lua_setfield: state at: -2 name: 'root';
			lua_pushboolean: state value: false;
			lua_setfield: state at: -2 name: 'vertically';
			lua_pushboolean: state value: true;
			lua_setfield: state at: -2 name: 'centeredxy'.

		self liblua assert: [ :ll | 
			ll lua_pcall: state nargs: 1 nresults: 0 ].

		self liblua
			on: state
			push:
				(MessageSend
					 receiver: #tidy
					 selector: #flat_xy_into
					 arguments: { 
							 n.
							 #nodes.
							 whxyExternalAddress }).

		[ 
		self liblua assert: [ :ll | 
			ll lua_pcall: state nargs: 3 nresults: 0 ].

		self liblua assert: [ :ll | 
			ll luaL_dostring: state chunk: 'tidy.free(r)' ].

		addr := self liblua
			        lua_getglobal: state name: 'nodes';
			        lua_touserdata: state at: -1.

		self liblua
			lua_pop: state nelements: 1;
			lua_pushnil: state;
			lua_setglobal: state name: addr.

		addr free ] timeToRun.

		[ 
		| canvas |
		canvas := RSCanvas new
			          @ RSCanvasController;
			          yourself.

		1 to: n do: [ :k | 
			| kk box label composite extent x y |
			kk := k - 1 * doubleByteSize.

			x := whxyExternalAddress float64AtOffset: kk.
			y := whxyExternalAddress float64AtOffset: n * doubleByteSize + kk.

			extent := extents at: k.

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

		whxyExternalAddress free.
		childrenExternalAddress free ]
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayoutPaperTreeFlatMemoryChunkUsingRoassalLayout [

	| tbl shapes edges lineBuilder layout |
	tbl := self liblua withOpenedLibsStateDo: [ :state | 
		       self liblua assert: [ :ll | 
			       ll luaL_loadstring: state chunk: '
	return {
	
        [1] = {w = 70, h = 30, c = {2, 3, 4, 8}},
        [2] = {w = 10, h = 50, c = {}},
        [3] = {w = 20, h = 30, c = {}},
        [4] = {w = 30, h = 30, c = {5, 7}},
        [5] = {w = 20, h = 50, c = {6}},
        [6] = {w = 40, h = 10, c = {}},
        [7] = {w = 20, h = 20, c = {}},
        [8] = {w = 30, h = 50, c = {9, 10}},
        [9] = {w = 30, h = 20, c = {}},
        [10] = {w = 10, h = 10, c = {}},

	}' ].

		       self liblua
			       assert: [ :ll | ll lua_pcall: state nargs: 0 nresults: 1 ];
			       on: state at: -1 ].

	"Some Roassal stuff."
	lineBuilder := RSLineBuilder horizontalBezier.
	layout := RSVanDerPloegLuaLineDrivenLayout new.

	"Remember the order, it is important."
	shapes := Dictionary new.
	edges := OrderedCollection new.

	tbl withIndexDo: [ :node :i | 
		| shape children |
		children := node at: #c.

		shape := RSNote new
			         color: Color white;
			         model: i;
			         withBorder;
			         cornerRadius: Float platinumRatio;
			         extent: (node at: #w) @ (node at: #h);
			         propertyVanDerPloegLuaImplChildrenSize: children size;
			         propertyVanDerPloegLuaImplIndex: i;
			         yourself.

		children do: [ :child | 
			edges add: [ lineBuilder edgeFrom: shape to: (shapes at: child) ] ].

		shapes at: i put: shape ].

	edges := edges collect: [ :aBlock | aBlock value ].

	layout
		vertically: false;
		rootShape: (shapes at: 1);
		on: shapes edges: edges.

	RSCanvas new
		@ RSCanvasController;
		addAll: shapes;
		open
]

{ #category : #tests }
NonLayeredTidyTreesTest >> testTreeLayoutPaperTreeFlatMemoryChunkUsingRoassalLayoutBiggestTree [

	| tbl shapes edges lineBuilder layout reifyChunkDuration buildShapesDuration layoutDuration showCanvasDuration luaDurations |
	reifyChunkDuration := [ 
	                      tbl := self liblua withOpenedLibsStateDo: [ 
		                             :state | 
		                             self liblua
			                             assert: [ :ll | 
				                             ll
					                             luaL_loadstring: state
					                             chunk:
						                             self bigtreeFileReference contents ];
			                             assert: [ :ll | 
				                             ll
					                             lua_pcall: state
					                             nargs: 0
					                             nresults: 1 ];
			                             on: state at: -1 ] ] timeToRun.

	"Some Roassal stuff."
	lineBuilder := RSLineBuilder horizontalBezier.
	layout := RSVanDerPloegLuaLineDrivenLayout new.

	"Remember the order, it is important."
	shapes := Dictionary new.
	edges := OrderedCollection new.

	buildShapesDuration := [ 
	                       | idx |
	                       idx := 1.
	                       tbl keysAndValuesDo: [ :k :node | 
		                       | shape children |
		                       children := node at: #c.

		                       shape := RSNote new
			                                color: Color white;
			                                model: k;
			                                withBorder;
			                                cornerRadius: Float platinumRatio;
			                                extent:
				                                (node at: #w) @ (node at: #h);
			                                
			                                propertyVanDerPloegLuaImplChildrenSize:
				                                children size;
			                                propertyVanDerPloegLuaImplIndex:
				                                idx;
			                                yourself.

		                       children do: [ :child | 
			                       edges add: [ 
				                       lineBuilder
					                       edgeFrom: shape
					                       to: (shapes at: child) ] ].

		                       shapes at: k put: shape.
		                       idx := idx + 1 ].

	                       edges := edges collect: [ :aBlock | 
		                                aBlock value ] ] timeToRun.

	layoutDuration := [ 
	                  luaDurations := layout
		                                  vertically: false;
		                                  rootShape:
			                                  (shapes at: #foAcmssi2tj);
		                                  on: shapes edges: edges ]
		                  timeToRun.

	showCanvasDuration := [ 
	                      RSCanvas new
		                      @ RSCanvasController;
		                      addAll: shapes;
		                      open ] timeToRun.

	Dictionary new
		at: #reifyChunkDuration put: reifyChunkDuration;
		at: #buildShapesDuration put: buildShapesDuration;
		at: #layoutDuration put: (Dictionary new
				 at: #total put: layoutDuration;
				 at: #detailed put: luaDurations;
				 yourself);
		at: #showCanvasDuration put: showCanvasDuration;
		inspect
]

{ #category : #accessing }
NonLayeredTidyTreesTest >> vanDerPloegPaperTreeVertical [

	^ '
	
		local tidy = require "non-layered-tidy-trees"
		
		local tree, itree = tidy.trees {
		
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

    local r = tree[1]		-- the root.

    tidy.layout { 
		root = r,
		vertically = true,
		centeredxy = true,
	 }

    local result = tidy.dbindrec (itree, "externalkey")

	 tidy.free(r)
	
	 return result
	'
]
