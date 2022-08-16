Class {
	#name : #MyVideoExport,
	#superclass : #RSAbstractContainerBuilder,
	#instVars : [
		'colors'
	],
	#category : #MyAnimations
}

{ #category : #hooks }
MyVideoExport >> animate: aTree [
	| box |
	box := self newBox: aTree.
	
	box color: (aTree parent 
		ifNil: [self colorFor: aTree]
		ifNotNil: [self colorFor: aTree parent]).
	self container add: box.
	self container newAnimation
		duration: (4000 - 3000 atRandom) milliSeconds;
		onStepDo: [ :t | 
			box cornerRadius: box width * 0.3* (aTree subQuads
				ifEmpty: [ t ]
				ifNotEmpty: [ 1 - ((t - 0.5) * 2) abs ] ).
			aTree parent ifNotNil: [ 
				box color: ((self colorFor: aTree parent)
					interpolateTo: (self colorFor: aTree)
					at: t) ] ];
		when: RSAnimationEndEvent do: [ :evt |
			aTree subQuads do: [ :quad | self animate: quad ].
			aTree subQuads ifNotEmpty: [ box remove ]
			
		].
	^ box
]

{ #category : #hooks }
MyVideoExport >> animationFor: node [
	| box |
	box := self newBox: node.
	
	^ self container transitionAnimation
		duration: 20 milliSeconds;
		when: RSAnimationStartEvent do: [ :evt |
			container add: box ];
		onStepDo: [ :t | 
			box cornerRadius: box width * 0.1 * t.
			box signalUpdate.
		];
		when: RSAnimationEndEvent do: [:evt | 
			box model subQuads ifNotEmpty: [ box remove ].
			];
		yourself
]

{ #category : #hooks }
MyVideoExport >> animationFor: index quadtree: aTree [
	| boxes |
	boxes := #().
	^ self container transitionAnimation
		when: RSAnimationStartEvent do: [ :evt | | nodes |
			self removeParents: (aTree quadsAtLevel: index - 1).
			nodes := aTree quadsAtLevel: index.
			boxes := nodes collect: [ :node | self newBox: node ].
			"boxes
				select: [ :box | box paint isNil ] 
				thenDo: [ :box | box color: Color white ]."
			self container addAll: boxes. ];
		onStepDo: [ :t | 
			boxes do: [ :box | 
				box cornerRadius: box width * 0.3 * t ].
			self container signalUpdate.
			 ];
		yourself
		
	
]

{ #category : #hooks }
MyVideoExport >> colorFor: aTree [
	^ aTree color ifNil: [ 
		"aTree parent color alpha: 0.2"
		Color colorFrom: '#1065c0' ]
]

{ #category : #hooks }
MyVideoExport >> computeColor: quad [
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

{ #category : #hooks }
MyVideoExport >> fillBoxesIn: aCanvas form: form [

	| extent box pixel |
	extent := form extent.
	1 to: extent x do: [ :x | 
		1 to: extent y do: [ :y | 
			pixel := form colorAt: x @ y.
			box := RSBox new
				       color: pixel;
				       size: 6;
				       position: x @ y * 5;
				       yourself.
			pixel alpha = 1 ifTrue: [ aCanvas add: box ] ] ]
]

{ #category : #hooks }
MyVideoExport >> form [
	^ ImageReadWriter formFromFileNamed: 'waifu.png'.
	"^ ImageReadWriter formFromFileNamed: 'pharologo.png'"
	"^ self iconNamed: #pharo"
]

{ #category : #initialization }
MyVideoExport >> initialize [
	super initialize.
	colors := Dictionary new.
]

{ #category : #hooks }
MyVideoExport >> newBox: quad [
	| rectangle |
	rectangle := quad rectangle.

	^ RSBox new
		model: quad;
		fromRectangle: rectangle;
		yourself
]

{ #category : #hooks }
MyVideoExport >> removeParents:	parents [
	parents select: [ :parent | parent isLeaf not and: [ parent isValid ] ]
		thenDo: [ :parent |(self container shapeFromModel: parent) remove ]
]

{ #category : #hooks }
MyVideoExport >> renderIn: aCanvas [
	| form tree |
	form := self form.
	'building boxes' traceCr.
	self fillBoxesIn: aCanvas form: form.
	'building quadtree' traceCr.
	tree := MyQuadTree withAll: aCanvas nodes.
	
	aCanvas nodes copy do: #remove.
	self computeColor: tree.
	
	"animations := (1 to: tree height) collect: [ :i | self animationFor: i quadtree: tree ]."
	
	self animate: tree.
	aCanvas 
		when: RSExtentChangedEvent 
		do: [ :evt | aCanvas  camera zoomToFit: aCanvas extent * 0.9 rectangle: tree rectangle. ].
	aCanvas color: Color veryVeryLightGray.
]

{ #category : #hooks }
MyVideoExport >> run [
	<script: 'self new run'>
	
	"self open."
	
	[
	'working' traceCr.
	self build.
	self canvas extent: 720 asPoint.
	'rendering' traceCr.
	self canvas videoExporter
		duration: 25 seconds;
		export] fork	
]
