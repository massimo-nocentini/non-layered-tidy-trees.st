"
I'm a variant of a vertical tree layout that uses a C implementation of the Van der Ploeg algorithm through a Lua interface.
"
Class {
	#name : #RSVanDerPloegLuaLineDrivenLayout,
	#superclass : #RSLineDrivenLayout,
	#instVars : [
		'vertically',
		'rootIndex'
	],
	#category : #'non-layered-tidy-trees-Roassal'
}

{ #category : #hook }
RSVanDerPloegLuaLineDrivenLayout >> doExecute: elements [

	self shouldNotImplement
]

{ #category : #public }
RSVanDerPloegLuaLineDrivenLayout >> liblua [

	^ LibLua uniqueInstance
]

{ #category : #hook }
RSVanDerPloegLuaLineDrivenLayout >> on: shapes edges: edges [

	| whxyExternalAddress childrenExternalAddress nshapes j addr nedges |
	nshapes := shapes size.
	nedges := edges size.

	whxyExternalAddress := ExternalAddress allocateFloat64Size:
		                       nshapes * 2.

	childrenExternalAddress := ExternalAddress allocateInt32Size:
		                           nshapes + nedges.

	j := 1.
	shapes do: [ :shape | 
		| idx |
		idx := shape propertyVanDerPloegLuaImplIndex.

		whxyExternalAddress
			float64WeightedAt: idx put: shape encompassingRectangle width;
			float64WeightedAt: nshapes + idx
			put: shape encompassingRectangle height.

		childrenExternalAddress
			int32WeightedAt: idx
			put: shape propertyVanDerPloegLuaImplChildrenSize.

		j := j + 1 ].

	edges do: [ :aLine | 
		childrenExternalAddress
			int32WeightedAt: j
			put: aLine to propertyVanDerPloegLuaImplIndex.

		j := j + 1 ].

	j := j - 1. "because `j` points to the next available memory location."
	self assert: nshapes + nedges = j.

	self liblua withOpenedLibsStateDo: [ :state | 
		self liblua
			assert: [ :ll | 
				ll
					luaL_dostring: state
					chunk: 'tidy = require "non-layered-tidy-trees"' ];
			lua_getglobal: state name: 'tidy';
			lua_getfield: state at: -1 name: 'reifyflatchunks';
			lua_remove: state at: -2;
			on: state push: nshapes;
			on: state push: whxyExternalAddress;
			on: state push: childrenExternalAddress;
			on: state push: self rootIndex.

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
			on: state push: self vertically;
			lua_setfield: state at: -2 name: 'vertically';
			on: state push: true;
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
							 nshapes.
							 #nodes.
							 whxyExternalAddress }).

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
			lua_setglobal: state name: 'nodes'.

		addr free ].

	shapes do: [ :shape | 
		| kk x y |
		kk := shape propertyVanDerPloegLuaImplIndex.

		x := whxyExternalAddress float64WeightedAt: kk.
		y := whxyExternalAddress float64WeightedAt: nshapes + kk.

		shape position: x @ y ].

	whxyExternalAddress free.
	childrenExternalAddress free
]

{ #category : #accessing }
RSVanDerPloegLuaLineDrivenLayout >> rootIndex [

	^ rootIndex
]

{ #category : #accessing }
RSVanDerPloegLuaLineDrivenLayout >> rootIndex: anObject [

	rootIndex := anObject
]

{ #category : #accessing }
RSVanDerPloegLuaLineDrivenLayout >> vertically [

	^ vertically
]

{ #category : #accessing }
RSVanDerPloegLuaLineDrivenLayout >> vertically: anObject [

	vertically := anObject
]
