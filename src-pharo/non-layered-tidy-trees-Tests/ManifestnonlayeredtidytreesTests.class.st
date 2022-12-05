"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestnonlayeredtidytreesTests,
	#superclass : #PackageManifest,
	#category : #'non-layered-tidy-trees-Tests-Manifest'
}

{ #category : #'code-critics' }
ManifestnonlayeredtidytreesTests class >> rulePrecedenceRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#NonLayeredTidyTreesTest #testTreeLayoutPaperTreeFlatMemoryChunk #false)) #'2022-12-05T17:14:50.788884+01:00') )
]

{ #category : #'code-critics' }
ManifestnonlayeredtidytreesTests class >> ruleUncommonMessageSendRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'non-layered-tidy-trees-Tests')) #'2022-11-24T15:34:53.648009+01:00') )
]
