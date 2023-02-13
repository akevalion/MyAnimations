Class {
	#name : #CTree,
	#superclass : #Object,
	#instVars : [
		'animations',
		'balls'
	],
	#category : #'MyAnimations-2023'
}

{ #category : #converting }
CTree >> asCanvas [
	| canvas |
	canvas := RSCanvas new.
	animations := OrderedCollection new.
	balls := OrderedCollection new.
	canvas add: self asShape.
	canvas color: Color black.
	animations do: [ :anime | canvas addAnimation: anime ].
	canvas zoomToFit.
	^ canvas
]

{ #category : #converting }
CTree >> asShape [
	| shapes n |
	n := 4.
	shapes := self generateTreeParts: n.
	shapes add: (self baseFor: n).
	shapes add: (self smalltalk).
	animations add: self ballAnimation.
	RSVerticalLineLayout new
		gapSize: 0;
		alignCenter;
		on: shapes.
	
	^ shapes asShape
]

{ #category : #converting }
CTree >> ballAnimation [
	| r |
	r := SharedRandom globalGenerator.
	^ RSTransitionAnimation new
		repeat;
		onStepDo: [ | time |
			time := balls first canvas currentTime.
			
			balls do: [ :ball | | timeGap lastTime gap |
				gap := 500.
				timeGap := ball propertyAt: #timeGap ifAbsentPut: [ r nextInteger: gap ].
				lastTime := ball propertyAt: #lastTime ifAbsentPut: [ time ].
				(time - lastTime) > timeGap ifTrue: [ 
					r next < 0.001 ifTrue: [
						gap := ball text = '.' 
							ifTrue: [ ball text: '0'; color: Color red. 100 ]
							ifFalse: [ ball text: '.'; color: Color green. 3000 ].
						ball 
							propertyAt: #timeGap put: (r nextInteger: gap);
							propertyAt: lastTime put: time.
					].
				].
			].
		].
]

{ #category : #converting }
CTree >> baseFor: n [
	| text |
	text := String streamContents: [ :stream |
		1 to: n do: [ :e | stream << '^' ].
		stream << '[..]'.
		1 to: n do: [ :e | stream << '^' ].
		].
	^ self label
		text: text;
		yourself
]

{ #category : #converting }
CTree >> branch: number [
	| line |
	line := RSGroup new.
	line add: (self leaf: '/').
	line addAll: ((1 to: number) collect: [:e | self dinamycBall: '.' ]).
	line add: (self leaf: '\').
	RSGridLayout new
		lineItemsCount: line size;
		gapSize: 3;
		on: line.
	^ line asShape
]

{ #category : #converting }
CTree >> dinamycBall: char [
	| ball |
	ball := self label
		text: char;
		yourself.
	balls add: ball.
	^ ball
]

{ #category : #converting }
CTree >> generateBranch: i [
	| branches |
	branches := { self branch: (i - 1)*2 + 1. self branch: i*2 + 1 }.
	RSVerticalLineLayout new
		gapSize: 0;
		alignCenter;
		on: branches.
	^ branches asShape
		
]

{ #category : #converting }
CTree >> generateTreeParts: number [
	| parts |
	parts := (1 to: number) 
		collect: [ :i | self generateBranch: i ]
		as: RSGroup.
	parts addFirst: self star. 
	^ parts
]

{ #category : #converting }
CTree >> label [
	^ RSLabel new
		text: '*';
		color: Color green;
		fontFamily: 'Courier New'
		yourself
]

{ #category : #converting }
CTree >> leaf: char [
	^ self label
		text: char;
		yourself
]

{ #category : #running }
CTree >> run [
	<script: 'self new run'>
	| canvas |
	canvas := self asCanvas.
	canvas open
]

{ #category : #converting }
CTree >> smalltalk [
	^ self label
		fontName: 'Zapfino';
		text: '[Merry X''mas!!!]';
		yourself
]

{ #category : #converting }
CTree >> star [
	| star anime |
	star := self label
		metricsProvider: (RSCairoFitMetricsProvider new );
		scaleBy: 3;
		color: Color yellow;
		yourself.
	anime := RSTransitionAnimation new
		duration: 1 seconds;
		repeat;
		scale: (NSScale linear
			domain: #(0 0.5 1);
			range: #(0 1 0));
		easing: RSEasingInterpolator backOut;
		onStepDo: [ :t | | position |
			position := star propertyAt: #opos ifAbsentPut: [ star position ].
			position := position - (1 * t).
			star matrix
				loadIdentity;
				translation: position;
				scaleBy: 3 + (1  * t).
			star resetBBox.
			 ].
	animations add: anime.
	^ star
]
