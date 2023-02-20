Class {
	#name : #MyQuadTree,
	#superclass : #Collection,
	#instVars : [
		'color',
		'subQuads',
		'isLeaf',
		'content',
		'rectangle',
		'parent'
	],
	#category : #'MyAnimations-Quadtree'
}

{ #category : #'instance creation' }
MyQuadTree class >> withAll: nodes [
	^ self withAll: nodes square: false
]

{ #category : #'instance creation' }
MyQuadTree class >> withAll: nodes square: isSquare [
	^ self new
		addAll: nodes square: isSquare;
		yourself
]

{ #category : #adding }
MyQuadTree >> add: aNode [
	self notYetImplemented
]

{ #category : #adding }
MyQuadTree >> addAll: aGroup square: isSquare [
	| rect |
	rect := aGroup encompassingRectangle.
	isSquare ifTrue: [ | ext |
		ext := rect extent max.
		
		rect := (rect floatCenter - (ext / 2)) corner: (rect floatCenter + (ext / 2))
		].
	self bulkLoad: aGroup rectangle: rect.
]

{ #category : #'private - adding' }
MyQuadTree >> addSoleChild: node [
	content := node.
	isLeaf := true
]

{ #category : #'private - adding' }
MyQuadTree >> bulkLoad: aRSGroup rectangle: aRectangle [
	rectangle := aRectangle.
	aRSGroup ifEmpty: [ ^ self ].
	
	(aRSGroup size = 1 and: [ aRSGroup first encompassingRectangle area >= rectangle area  ])
		ifTrue: [ ^ self addSoleChild: aRSGroup first ].
	subQuads := self computeAreas collectWithIndex: [ :area :index |
		| shapesInArea child  |
		shapesInArea := aRSGroup select: [ :box | (area containsPoint: box position) ].
		child := self class new.
		child parent: self.
		child bulkLoad: shapesInArea rectangle: area.
		child ].

]

{ #category : #accessing }
MyQuadTree >> color [
	^ color
]

{ #category : #accessing }
MyQuadTree >> color: aColor [
	color := aColor
]

{ #category : #'private - adding' }
MyQuadTree >> computeAreas [
	| center |
	center := rectangle floatCenter.
	^ { 
		center corner: rectangle corner.
		center corner: rectangle topRight.
		rectangle origin corner: center.
		center corner: rectangle bottomLeft.
	 }

]

{ #category : #accessing }
MyQuadTree >> content [
	^ content
]

{ #category : #enumerating }
MyQuadTree >> do: aBlock [
	isLeaf ifTrue: [ ^ aBlock value: content ].
	self subQuadsDo: [ :quad | quad do: aBlock ]
]

{ #category : #accessing }
MyQuadTree >> height [
	| max |
	self isLeaf
		ifTrue: [ ^ 1 ].
	max := 0.
	self subQuadsDo: [ :quad | max := max max: quad height ].
	
	max isZero ifTrue: [ ^ 0 ].
	^ 1 + max.
]

{ #category : #initialization }
MyQuadTree >> initialize [
	super initialize.
	isLeaf := false.
	subQuads := #().
]

{ #category : #testing }
MyQuadTree >> isLeaf [
	^ isLeaf
]

{ #category : #testing }
MyQuadTree >> isValid [
	^ subQuads notEmpty
]

{ #category : #accessing }
MyQuadTree >> parent [
	^ parent
]

{ #category : #accessing }
MyQuadTree >> parent: aTree [
	parent := aTree
]

{ #category : #enumerating }
MyQuadTree >> quadsAtLevel: aNumber [
	| list |
	list := OrderedCollection new.
	aNumber < 1 ifTrue: [ ^ list ].
	self quadsAtLevel: aNumber in: list level: 1.
	^ list
]

{ #category : #enumerating }
MyQuadTree >> quadsAtLevel: aNumber in: list level:	level [
	aNumber = level
		ifTrue: [ list add: self ]
		ifFalse: [ self subQuadsDo: [ :quad | quad quadsAtLevel: aNumber in: list level: level + 1 ] ]
	
]

{ #category : #accessing }
MyQuadTree >> rectangle [
	^ rectangle
]

{ #category : #removing }
MyQuadTree >> remove: oldObject ifAbsent: anExceptionBlock [ 
	self notYetImplemented
]

{ #category : #accessing }
MyQuadTree >> subQuads [
	^ subQuads
]

{ #category : #enumerating }
MyQuadTree >> subQuadsDo: aFullBlockClosure [ 
	subQuads
		select: [ :quad | quad notNil ]
		thenDo: [ :quad | aFullBlockClosure value: quad ]
]

{ #category : #enumerating }
MyQuadTree >> withAllNodesInAmplitud [
	| list todo |
	list := OrderedCollection new: 1000.
	todo := LinkedList new.
	todo add: self.
	[todo isEmpty ] whileFalse: [ | current |
		current := todo removeFirst.
		list add: current.
		todo addAll: current subQuads.
		].
	^ list
]
