Class {
	#name : #MyQuadTreeAnimation,
	#superclass : #RSAbstractContainerBuilder,
	#instVars : [
		'colors',
		'form'
	],
	#category : #'MyAnimations-Quadtree'
}

{ #category : #animation }
MyQuadTreeAnimation >> animate: aTree [
	| box canvas |
	box := self newBox: aTree.
	canvas := self container.
	box color: (aTree parent 
		ifNil: [ self colorFor: aTree ]
		ifNotNil: [ self colorFor: aTree parent ]).
	canvas add: box.
	canvas newAnimation
		duration: self duration;
		onStepDo: [ :t | 
			box cornerRadius: box width * 0.3 * (aTree subQuads
				ifEmpty: [ t ]
				ifNotEmpty: [ 1 - ((t - 0.5) * 2) abs ] ).
			aTree parent ifNotNil: [ 
				box color: ((self colorFor: aTree parent)
					interpolateTo: (self colorFor: aTree)
					at: t) ] ];
		when: RSAnimationEndEvent do: [ :evt |
			aTree height > 2 ifTrue: [ 
				aTree subQuads do: [ :quad | self animate: quad ].
				aTree subQuads ifNotEmpty: [ box remove ]
			] ifFalse: [ 
				aTree color ifNotNil: [ box cornerRadius: 0 ]
				 ].
		].
	^ box
]

{ #category : #accessing }
MyQuadTreeAnimation >> colorFor: aTree [
	^ aTree color ifNil: [ 
		"aTree parent color alpha: 0.2"
		Color colorFrom: '#1065c0' ]
]

{ #category : #private }
MyQuadTreeAnimation >> computeColor: quad [
	quad color: (quad isLeaf
		ifTrue: [ quad content color ]
		ifFalse: [ | baseColor |
			baseColor := nil.
			quad subQuadsDo: [ :aQuad | | aNewColor |
				aNewColor := self computeColor: aQuad.
				aNewColor ifNotNil: [ 
					baseColor := baseColor
						ifNil: [ aNewColor ]
						ifNotNil: [ baseColor interpolateTo: aNewColor at: 0.5 ] ] ].
			baseColor ] ).
	^ quad color
]

{ #category : #private }
MyQuadTreeAnimation >> directory [
	^ (IceRepository repositories detect: [ :each | each name = 'MyAnimations' ]) repositoryDirectory / 'img'
]

{ #category : #animation }
MyQuadTreeAnimation >> duration [
	^ (1500 - 1000 atRandom) milliSeconds
]

{ #category : #private }
MyQuadTreeAnimation >> fillBoxesIn: aCanvas [

	| extent box pixel |
	extent := form extent.
	1 to: extent x do: [ :x | 
		1 to: extent y do: [ :y | 
			pixel := form colorAt: x @ y.
			box := RSBox new
				       color: pixel;
				       size: 5;
				       position: x @ y * 4;
				       yourself.
			pixel alpha = 1 ifTrue: [ aCanvas add: box ] ] ]
]

{ #category : #accessing }
MyQuadTreeAnimation >> form [
	^ form
]

{ #category : #accessing }
MyQuadTreeAnimation >> form: aForm [
	form := aForm
]

{ #category : #initialization }
MyQuadTreeAnimation >> initialize [
	super initialize.
	colors := Dictionary new.
]

{ #category : #forms }
MyQuadTreeAnimation >> mikuForm [
	^ ImageReadWriter formFromFileNamed: self directory / 'miku.png'
]

{ #category : #private }
MyQuadTreeAnimation >> newBox: quad [
	| rectangle |
	rectangle := quad rectangle.

	^ RSBox new
		model: quad;
		position: rectangle floatCenter;
		extent: rectangle extent + 0.1;
		yourself
]

{ #category : #forms }
MyQuadTreeAnimation >> pharoLogoForm [
	^ ImageReadWriter formFromFileNamed: self directory / 'pharologo.png'
]

{ #category : #private }
MyQuadTreeAnimation >> removeParents:	parents [
	parents select: [ :parent | parent isLeaf not and: [ parent isValid ] ]
		thenDo: [ :parent |(self container shapeFromModel: parent) remove ]
]

{ #category : #hooks }
MyQuadTreeAnimation >> renderIn: aCanvas [
	| tree |
	'building boxes' traceCr.
	self fillBoxesIn: aCanvas.
	'building quadtree' traceCr.
	tree := MyQuadTree withAll: aCanvas nodes square: true.
	aCanvas nodes copy do: #remove.
	self computeColor: tree.
	self animate: tree.
	
	aCanvas 
		when: RSExtentChangedEvent 
		do: [ :evt | aCanvas  camera zoomToFit: aCanvas extent * 0.9 rectangle: tree rectangle. ].
	aCanvas color: Color veryVeryLightGray.
]

{ #category : #running }
MyQuadTreeAnimation >> run [
	<script: 'self new run'>
	self form: self mikuForm.
	self form: self pharoLogoForm.
	self form: self waifu2Form.
	"self form: (self iconNamed: 'pharo')."
	"self open."
	
	[
	'working' traceCr.
	self build.
	self canvas extent: 720 asPoint.
	'rendering' traceCr.
	self canvas videoExporter
		duration: 10 seconds;
		export] fork	
]

{ #category : #forms }
MyQuadTreeAnimation >> waifu2Form [
	^ ImageReadWriter formFromFileNamed: self directory / 'waifu2.png'
]

{ #category : #forms }
MyQuadTreeAnimation >> waifuForm [
	^ ImageReadWriter formFromFileNamed: self directory / 'waifu.png'
]
