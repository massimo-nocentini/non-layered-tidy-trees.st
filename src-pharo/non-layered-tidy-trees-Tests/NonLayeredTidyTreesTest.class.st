Class {
	#name : 'NonLayeredTidyTreesTest',
	#superclass : 'LibLuaAbstractTest',
	#traits : 'TIceImagesExporting',
	#classTraits : 'TIceImagesExporting classTrait',
	#category : 'non-layered-tidy-trees-Tests',
	#package : 'non-layered-tidy-trees-Tests'
}

{ #category : 'testing' }
NonLayeredTidyTreesTest class >> isAbstract [

	^ false
]

{ #category : 'utilities' }
NonLayeredTidyTreesTest >> bigtreeFileReference [

	^ './pharo-local/iceberg/massimo-nocentini/non-layered-tidy-trees.st/lua-test-data/big-tree.lua'
		  asFileReference
]

{ #category : 'utilities' }
NonLayeredTidyTreesTest >> highlightEmptyAreasLuaChunk: aChunk aCanvas: aCanvas highlightEmptyAreas: showHighlightShapes [

	self liblua withOpenedLibsStateDo: [ :state | 
		| table contourPairs shapes |
		self liblua
			assert: [ :ll | ll luaL: state dostring: aChunk ];
			on: state push: #result;
			in: [ :ll | table := ll on: state at: -1 ];
			on: state push: #contourpairs;
			in: [ :ll | contourPairs := ll on: state at: -1 ];
			lua: state pop: 2.

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
				         model: (v at: #external_key);
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

					                ll luaL: state dostring: chunk ].

				                self liblua
					                on: state push: #bottom;
					                in: [ :ll | bottom := ll on: state at: -1 ];
					                lua: state pop: 1.

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

		"contourPairs inspect."

		self liblua assert: [ :ll | 
			ll luaL: state dostring: 'tidy.free(r)' ] ]
]

{ #category : 'utilities' }
NonLayeredTidyTreesTest >> paperTree: chunk onCanvas: aCanvas [

	self liblua withOpenedLibsStateDo: [ :state | 
		| table |
		self liblua assert: [ :ll | ll luaL: state loadstring: chunk ].

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

{ #category : 'utilities' }
NonLayeredTidyTreesTest >> smalltreeFileReference [

	^ './pharo-local/iceberg/massimo-nocentini/non-layered-tidy-trees.st/lua-test-data/small-tree.lua'
		  asFileReference
]

{ #category : 'export compiled methods' }
NonLayeredTidyTreesTest >> testExportCompiledMethods [

	self
		exportCompiledMethod:
			NonLayeredTidyTreesTest >> #vanDerPloegPaperTreeVertical;
		exportCompiledMethod:
			NonLayeredTidyTreesTest >> #testTreeLayoutIssue;
		exportCompiledMethod:
			NonLayeredTidyTreesTest >> #treeLayoutIssueLuaChunk;
		exportCompiledMethod:
			NonLayeredTidyTreesTest >> #treeLayoutIssue1LuaChunk;
		exportCompiledMethod: RSVanDerPloegLuaLineDrivenLayout >> #on:edges:
]

{ #category : 'tests' }
NonLayeredTidyTreesTest >> testTreeLayout3_small [

	| nodesCount externalAddress contents |
	contents := self smalltreeFileReference contents.
	nodesCount := contents lines size - 2.

	externalAddress := Float64TypedExternalAddress allocate:
		                   4 * nodesCount.

	self liblua withOpenedLibsStateDo: [ :state | 
		self liblua
			luaL_requiref: state name: 'non-layered-tidy-trees' let: 'tidy';
			assert: [ :ll | ll luaL: state loadstring: contents ];
			assert: [ :ll | ll lua_pcall: state nargs: 0 lets: #( spec ) ];
			assert: [ :ll | 
				ll luaL: state dostring: 'tree, itree = tidy.trees (spec)' ];
			assert: [ :ll | 
				ll luaL: state dostring: 'r = tree.foCcmssi4sv' ].

		self liblua assert: [ :ll | 
			ll luaL: state dostring: '
    tidy.layout { 
		root = r,
		vertically = false,
		centeredxy = true,
	 }
' ].

		self liblua
			on: state push: #tidy;
			lua: state
			get: -1
			field: 'flat_xywh_into'
			remove: true;
			on: state push: #r;
			on: state push: externalAddress.

		self liblua
			assert: [ :ll | ll lua_pcall: state nargs: 2 nresults: 0 ];
			assert: [ :ll | ll luaL: state dostring: 'tidy.free(r)' ] ].

	self export: nil pathSuffix: '' onCanvasDo: [ :canvas :_ | 
		1 to: nodesCount do: [ :kk | 
			| box label composite x y w h k |
			k := kk - 1 * 4.
			x := externalAddress at: k + 1.
			y := externalAddress at: k + 2.
			w := externalAddress at: k + 3.
			h := externalAddress at: k + 4.

			box := RSNote new
				       withBorder;
				       cornerRadius: Float goldenRatio;
				       color: Color white;
				       extent: w @ h;
				       position: x @ y;
				       yourself.

			label := RSLabel new
				         model: kk;
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

			canvas addShape: composite ] ].

	externalAddress free
]

{ #category : 'tests' }
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
		contourpairscb = function (sr, cl, dist) table.insert (contourpairs, { itree[sr], itree[cl], })	end,
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

{ #category : 'tests' }
NonLayeredTidyTreesTest >> testTreeLayoutIssue [

	"https://github.com/Klortho/d3-flextree/issues/1#issuecomment-369856820"

	self
		export: self treeLayoutIssueLuaChunk
		pathSuffix: ''
		onCanvasDo: [ :canvas :chunk | 
			| table |
			self liblua withOpenedLibsStateDo: [ :state | 
				self liblua assert: [ 
					self liblua luaL: state loadstring: chunk ].

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

{ #category : 'tests' }
NonLayeredTidyTreesTest >> testTreeLayoutIssue1 [

	self
		export: self treeLayoutIssue1LuaChunk 
		pathSuffix: ''
		onCanvasDo: [ :canvas :chunk | 
			| table |
			"https://github.com/Klortho/d3-flextree/issues/1#issuecomment-369856820"
			self liblua withOpenedLibsStateDo: [ :state | 
				self liblua assert: [ :ll | 
					ll luaL: state loadstring: chunk ].

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

{ #category : 'tests' }
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

{ #category : 'tests' }
NonLayeredTidyTreesTest >> testTreeLayoutPaperTreeFlatMemoryChunkUsingRoassalLayout [

	| tbl shapes edges lineBuilder layout |
	tbl := self liblua withOpenedLibsStateDo: [ :state | 
		       self liblua assert: [ :ll | 
			       ll luaL: state loadstring: '
	return {
	
        [1] = {w = 70, h = 30, c = {2, 11, 4, 8}},
	     [2] = {w = 10, h = 50, c = {}},
		  [3] = {w = 20, h = 30, c = {}},
        [4] = {w = 30, h = 30, c = {5, 7}},
        [5] = {w = 20, h = 50, c = {6}},
        [6] = {w = 40, h = 10, c = {}},
        [7] = {w = 20, h = 20, c = {}},
        [8] = {w = 30, h = 50, c = {9, 10}},
        [9] = {w = 30, h = 20, c = {}},
        [10] = {w = 10, h = 10, c = {}},
		  [11] = {w = 10, h = 100, c = { 3 } },
	}' ].

		       self liblua
			       assert: [ :ll | ll lua_pcall: state nargs: 0 nresults: 1 ];
			       on: state at: -1 ].

	"Some Roassal stuff."
	lineBuilder := RSLineBuilder horizontalBezier
		               withBorderAttachPoint;
		               yourself.
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
		gapsPoint: 0 @ 0 * Float goldenRatio;
		rootShape: (shapes at: 1);
		on: shapes edges: edges.

	self
		export: shapes
		pathSuffix: 'clean'
		onCanvasDo: [ :aCanvas :aCollectionOfShapes | 
		aCanvas addAll: aCollectionOfShapes ].

	layout
		vertically: false;
		gapsPoint: 10 @ 0 * Float goldenRatio;
		rootShape: (shapes at: 1);
		on: shapes edges: edges.

	self
		export: shapes
		pathSuffix: 'depthgaps'
		onCanvasDo: [ :aCanvas :aCollectionOfShapes | 
		aCanvas addAll: aCollectionOfShapes ].

	layout
		vertically: false;
		gapsPoint: 0 @ 5 * Float goldenRatio;
		rootShape: (shapes at: 1);
		on: shapes edges: edges.

	self
		export: shapes
		pathSuffix: 'breadthgaps'
		onCanvasDo: [ :aCanvas :aCollectionOfShapes | 
		aCanvas addAll: aCollectionOfShapes ].

	layout
		vertically: false;
		gapsPoint: 10 @ 5 * Float goldenRatio;
		rootShape: (shapes at: 1);
		on: shapes edges: edges.

	self
		export: shapes
		pathSuffix: 'depthgaps-breadthgaps'
		onCanvasDo: [ :aCanvas :aCollectionOfShapes | 
		aCanvas addAll: aCollectionOfShapes ]
]

{ #category : 'tests' }
NonLayeredTidyTreesTest >> testTreeLayoutPaperTreeFlatMemoryChunkUsingRoassalLayoutBiggestTree [

	| tbl shapes edges lineBuilder layout reifyChunkDuration buildShapesDuration layoutDuration showCanvasDuration luaDurations |
	self timeLimit: 5 minute.

	reifyChunkDuration := [ 
	                      tbl := self liblua withOpenedLibsStateDo: [ 
		                             :state | 
		                             self liblua
			                             assert: [ :ll | 
				                             ll
					                             luaL: state
					                             loadstring:
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

	showCanvasDuration := [ "self
		                      export: shapes
		                      pathSuffix: 'wholetree'
		                      onCanvasDo: [ :aCanvas :_ | 
		                      aCanvas addAll: shapes ]"
	                      RSCanvas new
		                      @ RSCanvasController;
		                      addAll: shapes;
		                      open ] timeToRun.

	self exportSlotsGraphOf: (Array streamContents: [ :aStream | 
			 | details |
			 details := { 
				            ('inputDuration: ' , luaDurations first asString).
				            ('parseDuration ' , luaDurations second asString).
				            ('layoutDuration ' , luaDurations third asString).
				            ('outputDuration ' , luaDurations fourth asString).
				            ('positioningDuration ' , luaDurations fifth asString) }.

			 aStream
				 nextPut: 'reifyChunkDuration: ' , reifyChunkDuration asString;
				 nextPut: 'buildShapesDuration: ' , buildShapesDuration asString;
				 nextPut: 'layoutDuration: ' , layoutDuration asString -> details;
				 nextPut: 'showCanvasDuration: ' , showCanvasDuration asString ])
]

{ #category : 'tests' }
NonLayeredTidyTreesTest >> testTreeLayoutPaperTreeWithInitialOffsets [

	| pos |
	pos := 20 @ 50.

	self
		export:
		(self vanDerPloegPaperTreeVerticalWithDepthBreadthOffsetPoint: pos)
		pathSuffix: 'vertical'
		onCanvasDo: [ :aCanvas :luaChunk | 
			self paperTree: luaChunk onCanvas: aCanvas.

			aCanvas
				addShape: (RSCircle new
						 radius: Float goldenRatio;
						 color: Color red translucent;
						 position: 0 @ 0;
						 yourself);
				addShape: (RSCircle new
						 radius: Float goldenRatio;
						 color: Color blue translucent;
						 position: pos;
						 yourself) ].

	self
		export: (self vanDerPloegPaperTreeVertical
				 copyReplaceAll: 'vertically = true'
				 with: 'vertically = false')
		pathSuffix: 'horizontal'
		onCanvasDo: [ :aCanvas :luaChunk | 
		self paperTree: luaChunk onCanvas: aCanvas ]
]

{ #category : 'Lua chunks' }
NonLayeredTidyTreesTest >> treeLayoutIssue1LuaChunk [

	^ '
		
	 local tidy = require "non-layered-tidy-trees"
		
	 local tree, itree = tidy.trees {
		
        [0] = {w = 40, h = 40, c = {1, 2}},
        [1] = {w = 40, h = 40, c = {}},
        [2] = {w = 40, h = 40, c = { 3 } },
        [3] = {w = 40, h = 40, c = { 4, 5 } },
        [4] = {w = 100, h = 40, c = {}},
        [5] = {w = 200, h = 40, c = {}},
    }

    local r = tree[0]		-- the root.

    tidy.layout { 
		root = r,
		vertically = true,
		centeredxy = true,
	 }

    local result = tidy.dbindrec (itree)

	 tidy.free(r)
	
	 return result
	'
]

{ #category : 'Lua chunks' }
NonLayeredTidyTreesTest >> treeLayoutIssueLuaChunk [

	^ '
	
	 local tidy = require "non-layered-tidy-trees"
		
	 local tree, itree = tidy.trees {
        [0] = {w = 40, h = 40, c = {1, 2}},
        [1] = {w = 40, h = 40, c = {}},
        [2] = {w = 40, h = 40, c = { 3, 4 } },
        [3] = {w = 100, h = 40, c = {}},
        [4] = {w = 200, h = 40, c = {}},
    }

    local r = tree[0]		-- the root.

    tidy.layout { 
		root = r,
		vertically = true,
		centeredxy = true,
	 }

    local result = tidy.dbindrec (itree)

	 tidy.free(r)
	
	 return result
'
]

{ #category : 'Lua chunks' }
NonLayeredTidyTreesTest >> vanDerPloegPaperTreeVertical [

	^ self vanDerPloegPaperTreeVerticalWithDepthBreadthOffsetPoint: 0 @ 0
]

{ #category : 'Lua chunks' }
NonLayeredTidyTreesTest >> vanDerPloegPaperTreeVerticalWithDepthBreadthOffsetPoint: aPoint [

	^ '
	
		local tidy = require "non-layered-tidy-trees"
		
		local tree, itree = tidy.trees {
		
        [1] = {w = 70, h = 30, c = {2, -3, 4, 8}},
        [2] = {w = 10, h = 50, c = {}},
        [-3] = {w = 10, h = 100, m = 10, c = { 3 } },
        [3] = {w = 20, h = 30, c = {}},
        [4] = {w = 30, h = 30, c = {5, 7}},
        [5] = {w = 20, h = 50, m = 5, c = {6}},
        [6] = {w = 40, h = 10, c = {}},
        [7] = {w = 20, h = 20, c = {}},
        [8] = {w = 30, h = 50, c = {9, 10}},
        [9] = {w = 30, h = 20, m = 5, c = {}},
        [10] = {w = 10, h = 10, c = {}},

    }

    local r = tree[1]		-- the root.

    tidy.layout { 
		root = r,
		vertically = true,
		centeredxy = true,
		x = ' , aPoint x asString , ',
		y = ' , aPoint y asString , ',
	 }

    local result = tidy.dbindrec (itree, "externalkey")

	 tidy.free(r)
	
	 return result
	'
]
