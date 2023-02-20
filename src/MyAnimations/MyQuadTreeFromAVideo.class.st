Class {
	#name : #MyQuadTreeFromAVideo,
	#superclass : #Object,
	#instVars : [
		'backgroundColor',
		'shapes'
	],
	#category : #'MyAnimations-Quadtree'
}

{ #category : #running }
MyQuadTreeFromAVideo >> colorFor: aTree [
	^ aTree content
		ifNil: [ | mix |
			mix := nil.
			aTree subQuads do: [ :quad | | col |
				col := (self colorFor: quad).
				mix ifNil: [ mix := col ]
				ifNotNil: [ mix := col interpolateTo: mix at: 0.5 ].
				].
			mix 
				ifNil: [ backgroundColor ]
				ifNotNil: [ mix ]
		] ifNotNil: [ aTree content color ]
]

{ #category : #running }
MyQuadTreeFromAVideo >> directory [
	^ (IceRepository repositories detect: [ :each | each name = 'MyAnimations' ]) repositoryDirectory.
]

{ #category : #running }
MyQuadTreeFromAVideo >> fillCanvas: canvas tree: aTree [
	| box |
	aTree subQuads ifEmpty: [
		box := self newBox: aTree.
		box color: (self colorFor: aTree).
		aTree content 
			ifNil: [ box cornerRadius: box width * 0.3 ]
			ifNotNil: [ box model: aTree content color ].
		canvas add: box
	] ifNotEmpty: [ 
		aTree subQuads do: [ :quad | self fillCanvas: canvas tree: quad ]
		]
	
	
]

{ #category : #running }
MyQuadTreeFromAVideo >> generateFromFile: file [
	| segmentator background original tree extent |
	segmentator := AIImageSegmentator new
		loadImage: file;
		numberOfSegments: 5;
		yourself.
	segmentator clusterImagePixels; segmentate.
	background := segmentator segmentedImage.
	original := segmentator originalImage.
	
	shapes := self pixelsFrom: background and: original.
	extent := original extent * 5.
	
	tree := MyQuadTree new 
		bulkLoad: shapes 
		rectangle: ((0 @ (0 - (extent x - extent y) ))
			corner: extent).
	self generateFromQuadTree: tree name: file basename.
]

{ #category : #running }
MyQuadTreeFromAVideo >> generateFromFolder: name [
	| directory size |
	directory := self directory / name.
	size := directory children size.
	(1 to: size - 1) do: [ :i |
		self generateFromFile: directory / (i asString, '.png')
	] displayingProgress: [ :i | 'Generating image ', i asString, '/', size asString ] every: 500
]

{ #category : #running }
MyQuadTreeFromAVideo >> generateFromQuadTree: tree name: name [
	| canvas base newName |
	canvas := RSCanvas new.
	canvas extent: 720@720.
	self fillCanvas: canvas tree: tree.
	canvas shapes 
		reject: [ :shape | shape model isNil ]
		thenDo: [ :shape | shape pushFront; extent: shape extent * 3 ].
	base := '0001.png' size.
	newName := name.
	base - name size timesRepeat: [ newName := '0', newName  ].
	canvas camera
		zoomToFit: canvas extent
		rectangle: tree rectangle.
	
	canvas pngExporter
		exportToFile: ('./out/', newName) asFileReference.
]

{ #category : #running }
MyQuadTreeFromAVideo >> generateVideoFromFolder: file [
	RSVideoExporter new
		fpsOutPut: 30;
		framesDirectory: file asFileReference;
		exportWithffmpeg: file.
]

{ #category : #initialization }
MyQuadTreeFromAVideo >> initialize [
	super initialize.
	backgroundColor := Color colorFrom: '#1065c0'
]

{ #category : #running }
MyQuadTreeFromAVideo >> newBox: quad [
	| rectangle |
	rectangle := quad rectangle.
	^ RSBox new
		position: rectangle floatCenter;
		extent: rectangle extent + 0.1;
		yourself
]

{ #category : #running }
MyQuadTreeFromAVideo >> pixelsFrom: background and: original [
	| noColor |
	shapes := RSGroup new: 20000.
	noColor := background colorAt: 1@1.
	
	1 to: original width do: [ :x |
		1 to: original height do: [ :y | | color |
			color := background colorAt: x@y.
			(color isTransparent or: [ color = noColor ]) ifFalse: [ 
				color := original colorAt: x@y.
				shapes add: (RSBox new
					size: 5;
					position: x @ y * 5;
					color: color;
					yourself).
			] ] ].
	^ shapes.
]

{ #category : #running }
MyQuadTreeFromAVideo >> run [
	<script: 'self new run'>
	self generateFromFolder: 'dance'.
	"self generateVideoFromFolder: 'out'"
]
