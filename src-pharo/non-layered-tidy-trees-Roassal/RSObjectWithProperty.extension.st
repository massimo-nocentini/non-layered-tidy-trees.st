Extension { #name : #RSObjectWithProperty }

{ #category : #'*non-layered-tidy-trees-Roassal' }
RSObjectWithProperty >> propertyVanDerPloegLuaImplChildrenSize [

	^ self propertyAt: #vdpChildrenSize
]

{ #category : #'*non-layered-tidy-trees-Roassal' }
RSObjectWithProperty >> propertyVanDerPloegLuaImplChildrenSize: anInteger [

	^ self propertyAt: #vdpChildrenSize put: anInteger
]

{ #category : #'*non-layered-tidy-trees-Roassal' }
RSObjectWithProperty >> propertyVanDerPloegLuaImplIndex [

	^ self propertyAt: #vdpIdx
]

{ #category : #'*non-layered-tidy-trees-Roassal' }
RSObjectWithProperty >> propertyVanDerPloegLuaImplIndex: anInteger [

	^ self propertyAt: #vdpIdx put: anInteger
]
