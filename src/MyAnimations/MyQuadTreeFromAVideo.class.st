Class {
	#name : #MyQuadTreeFromAVideo,
	#superclass : #RSAbstractContainerBuilder,
	#instVars : [
		'colors'
	],
	#category : #'MyAnimations-Quadtree'
}

{ #category : #running }
MyQuadTreeFromAVideo >> colorFor: aTree [
	^ aTree color
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
		canvas add: box
	] ifNotEmpty: [ 
		aTree subQuads do: [ :quad |
			self fillCanvas: canvas tree: aTree.
			 ]
	 ].
	
]

{ #category : #running }
MyQuadTreeFromAVideo >> generateFromFile: file [
	| segmentator background original tree extent |
	segmentator := AIImageSegmentator new
		loadImage: file;
		numberOfSegments: 2;
		yourself.
	segmentator clusterImagePixels; segmentate.
	background := segmentator segmentedImage.
	original := segmentator originalImage.
	
	shapes := self pixelsFrom: background and: original.
	extent := shapes extent.
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
	(1 to: size) do: [ :i |
		self generateFromFile: directory / (i asString, '.png')
	] displayingProgress: [ :i | 'Generating image ', i asString, '/', size asString ] every: 500
]

{ #category : #running }
MyQuadTreeFromAVideo >> generateFromQuadTree: tree name: name [
	| canvas |
	canvas := RSCanvas new.
	canvas extent: 720@720.
	self fillCanvas: canvas tree: tree.
	canvas camera
		zoomToFit: tree rectangle
		extent: canvas extent.
	canvas pngExporter
		exportToFile: ('out/', name) asFileReference.
]

{ #category : #running }
MyQuadTreeFromAVideo >> newBox: quad [
	| rectangle |
	rectangle := quad rectangle.

	^ RSBox new
		model: quad;
		position: rectangle floatCenter;
		extent: rectangle extent + 0.1;
		yourself
]

{ #category : #running }
MyQuadTreeFromAVideo >> pixelsFrom: background and: original [
	shapes := RSGroup new: 1000.
	1 to: original width do: [ :x |
		1 to: original height do: [ :y | | color |
			color := background colorAt: x@y.
			color isTransparent ifTrue: [ 
				color := original colorAt: x@y.
				shapes add: (RSBox new
					size: 5;
					position: x @ y * 4;
					color: color;
					yourself).
			] ] ].
	^ shapes.
]

{ #category : #running }
MyQuadTreeFromAVideo >> run [
	<script: 'self new run'>
	self generateFromFolder: 'dance'.
]
