Class {
	#name : #BaselineOfnonlayeredtidytreesst,
	#superclass : #BaselineOf,
	#category : #BaselineOfnonlayeredtidytreesst
}

{ #category : #baselines }
BaselineOfnonlayeredtidytreesst >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			baseline: 'LibLuast'
			with: [ spec repository: 'github://massimo-nocentini/LibLua-st' ].

		spec
			baseline: 'ContainersEssentials'
			with: [ 
			spec repository: 'github://massimo-nocentini/Containers-Essentials' ].

		spec
			package: 'non-layered-tidy-trees-Roassal';
			package: 'non-layered-tidy-trees-Tests' ]
]
