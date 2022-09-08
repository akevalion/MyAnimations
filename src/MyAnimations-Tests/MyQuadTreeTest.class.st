"
A MyQuadTreeTest is a test class for testing the behavior of MyQuadTree
"
Class {
	#name : #MyQuadTreeTest,
	#superclass : #TestCase,
	#category : #'MyAnimations-Tests'
}

{ #category : #tests }
MyQuadTreeTest >> testAddNElements [
	| tree boxes n |
	n := 10.
	(1 to: n) do: [ :index | 
		boxes := (1 to: index) collect: [ :each | 
			RSBox new
				model: each;
				extent: 10@10;
				yourself ] as: RSGroup.
		RSGridLayout on: boxes.
		tree := MyQuadTree withAll: boxes.
		
		self assert: tree size equals: index.
		self assert: tree rectangle equals: boxes encompassingRectangle.
	]
	
]

{ #category : #tests }
MyQuadTreeTest >> testBasic [
	| tree |
	tree := MyQuadTree new.
	self deny: tree isLeaf.
	self assert: tree rectangle equals: nil.
	self deny: tree isValid
]

{ #category : #tests }
MyQuadTreeTest >> testHeight [
	| tree group |
	tree := MyQuadTree new.
	self assert: tree height equals: 0.
	tree := MyQuadTree withAll: { RSBox new } asGroup.
	self assert: tree height equals: 2.
	
	
	group := { RSBox new. RSBox new } asGroup.
	RSGridLayout on: group.
	tree := MyQuadTree withAll: group.
	self assert: tree height equals: 2.
	
	
	group := { RSBox new. RSBox new. RSBox new } asGroup.
	RSGridLayout on: group.
	tree := MyQuadTree withAll: group.
	self assert: tree height equals: 3.
]
