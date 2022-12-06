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

{ #category : #public }
RSVanDerPloegLuaLineDrivenLayout >> liblua [

	^ LibLua uniqueInstance
]

{ #category : #hook }
RSVanDerPloegLuaLineDrivenLayout >> on: elements edges: edges [

	| whxyExternalAddress childrenExternalAddress n j doubleByteSize longByteSize addr nedges |
	doubleByteSize := ExternalType double byteSize.
	longByteSize := ExternalType long byteSize.

	n := elements size.
	nedges := edges size.

	whxyExternalAddress := ExternalAddress allocate:
		                       doubleByteSize * n * 2.

	childrenExternalAddress := ExternalAddress allocate:
		                           longByteSize * (n + nedges).

	j := 0.
	elements do: [ :shape | 
		| offset |
		offset := (shape propertyAt: #vdpIdx) - 1.

		whxyExternalAddress
			float64AtOffset: offset * doubleByteSize
			put: shape encompassingRectangle width;
			float64AtOffset: n + offset * doubleByteSize
			put: shape encompassingRectangle height.

		childrenExternalAddress
			int32AtOffset: offset * longByteSize
			put: (shape propertyAt: #vdpChildrenSize).

		j := j + 1 ].

	edges do: [ :aLine | 
		childrenExternalAddress
			int32AtOffset: j * longByteSize
			put: (aLine to propertyAt: #vdpIdx).
		j := j + 1 ].

	self assert: n + nedges = j.

	self liblua withOpenedLibsStateDo: [ :state | 
		self liblua
			assert: [ :ll | 
				ll
					luaL_dostring: state
					chunk: 'tidy = require "non-layered-tidy-trees"' ];
			lua_getglobal: state name: 'tidy';
			lua_getfield: state at: -1 name: 'reifyflatchunks';
			lua_remove: state at: -2;
			lua_pushinteger: state value: n;
			lua_pushlightuserdata: state externalAddress: whxyExternalAddress;
			lua_pushlightuserdata: state
			externalAddress: childrenExternalAddress;
			lua_pushinteger: state value: self rootIndex.

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
			lua_pushboolean: state value: self vertically;
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

		addr free ].

	elements do: [ :shape | 
		| kk x y |
		kk := (shape propertyAt: #vdpIdx) - 1.

		x := whxyExternalAddress float64AtOffset: kk * doubleByteSize.
		y := whxyExternalAddress float64AtOffset: n + kk * doubleByteSize.

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
