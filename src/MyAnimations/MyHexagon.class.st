Class {
	#name : #MyHexagon,
	#superclass : #RSObject,
	#instVars : [
		'index',
		'level',
		'maxLevel',
		'outers',
		'mids',
		'struts',
		'quars',
		'subHxgs'
	],
	#category : #'MyAnimations-Hexagon'
}

{ #category : #accessing }
MyHexagon >> index [

	^ index
]

{ #category : #accessing }
MyHexagon >> index: anObject [

	index := anObject
]

{ #category : #initialization }
MyHexagon >> initialize [
	super initialize.
	outers := (1 to: 6) collect: [ :i | 0@0 ].
	mids := (1 to: 6) collect: [ :i | 0@0 ].
	struts := (1 to: 6) collect: [ :i | 0@0 ].
	quars := (1 to: 12) collect: [ :i | 0@0 ].
	
	
]

{ #category : #accessing }
MyHexagon >> level [

	^ level
]

{ #category : #accessing }
MyHexagon >> level: anObject [

	level := anObject
]

{ #category : #accessing }
MyHexagon >> maxLevel [

	^ maxLevel
]

{ #category : #accessing }
MyHexagon >> maxLevel: anObject [
	maxLevel := anObject.
	level < maxLevel ifFalse: [ ^ self ].
	level := level + 1.
	subHxgs := (1 to: 7) collect: [ :i | self class new
		index: i;
		level: level;
		maxLevel: maxLevel ]
]

{ #category : #private }
MyHexagon >> pointInP1: v1 p2: v2 ratio: ratio [
	^ (v1 * ratio) + (v2 * (1 - ratio))
	
]

{ #category : #rendering }
MyHexagon >> renderHxgIn: aCanvas [
	aCanvas add: (RSPolygon new
		points: outers;
		noPaint; 
		border: (RSBorder new color: Color green );
		yourself)
]

{ #category : #rendering }
MyHexagon >> renderIn: aCanvas [
	self renderHxgIn: aCanvas.
	self renderSubHxgsIn: aCanvas.
]

{ #category : #rendering }
MyHexagon >> renderSubHxgsIn: aCanvas [
	| width |
	width := 1- (0.2*level).
	mids with: struts do: [ :mid :strut | 
		aCanvas add: (RSLine new
			startPoint: mid;
			color: Color green;
			width: width;
			endPoint: strut;
			yourself)
		 ].
	1 to: 12 - 1 by: 2 do: [ :i | 
		aCanvas add: (RSLine new
			startPoint: (quars at: i);
			endPoint: (quars at: i + 1);
			color: Color green;
			width: width;
			yourself)
		].
	0 to: struts size - 1 do: [ :i | | j |
		j := (i+1) % struts size.
		aCanvas add: (RSLine new
			startPoint: (struts at: i +1);
			endPoint: (struts at: j + 1);
			color: Color green;
			width: width;
			yourself)
		 ].
	level < maxLevel ifFalse: [ ^ self ].
	
	subHxgs do: [ :each | each renderSubHxgsIn: aCanvas ].

]

{ #category : #private }
MyHexagon >> update: values strut: strutF perlin: perlin [
	| strut |
	outers := values.
	self updateMids.
	self updateQuars.
	strut := self updateStruts: perlin strut: strutF.
	level < maxLevel ifFalse: [ ^ self ].
	
	strut := strut + 1.
	subHxgs last update: struts strut: strut perlin: perlin.
	strut := strut + 0.1.
	0 to: 5 do: [ :i | | j k group sub |
		j := (i + 1) % 6 + 1.
		k := (i * 2) % 12 + 1.
		group := { 
			mids at: i+1. quars at: k. quars at: k+1. 
			mids at: j. struts at: j. struts at: i+1 }.
		sub := subHxgs at: i+1.
		sub update: group strut: strut perlin: perlin.
		strut := strut + 0.1.
	]
]

{ #category : #private }
MyHexagon >> updateMids [
	mids := (1 to: mids size) collect: [ :i | | j |
		j := i % mids size.
		self pointInP1: (outers at: i) p2: (outers at: j + 1) ratio: 0.5 ].
	
]

{ #category : #private }
MyHexagon >> updateQuars [
	0 to: 11 by: 2 do: [ :i | | j |
		j := (i/2 + 1) % mids size + 1.
		quars at: i+1 put: (self pointInP1: (mids at: i/2 + 1)  p2: (outers at: j) ratio: 0.5).
		quars at: i+2 put: (self pointInP1: (outers at: j)  p2: (mids at: j) ratio: 0.5) ]
]

{ #category : #private }
MyHexagon >> updateStruts: perlin strut: strutF [
	| strut |
	strut := strutF.
	struts := (0 to: struts size - 1) collect: [ :i | | j strutRatio newStrut |
		j := (i + 3) % 6.
		strutRatio := 1 - ((perlin noise: strutF and: 0)*0.75).
		newStrut := self pointInP1: (mids at: i + 1) p2: (mids at: j + 1)  ratio: strutRatio.
		strut := strut + 0.1.
		newStrut
		 ].
	^ strut
]
