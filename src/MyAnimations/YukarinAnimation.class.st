Class {
	#name : #YukarinAnimation,
	#superclass : #RSAbstractContainerBuilder,
	#category : #'MyAnimations-Yukarin'
}

{ #category : #hooks }
YukarinAnimation >> computeFrames [
	| folder |
	folder := (IceRepository repositories detect: [ :each | each name = 'MyAnimations' ]) repositoryDirectory.
	 ^ (1 to: 10) collect: [ :i |
		ImageReadWriter formFromFileNamed: folder / ('yukarin/' , i asString , '.png') ]
]

{ #category : #running }
YukarinAnimation >> export [
	self container videoExporter
		p1080;
		duration: 10 seconds;
		export
]

{ #category : #hooks }
YukarinAnimation >> newEllipse: letter [
	^
	{RSEllipse new
		size: 20;
		color: Color green muchDarker translucent;
		border: (RSBorder new color: Color black; width: 0.1);
		yourself.
	RSLabel new
		fontName: 'Optima';
		text: letter;
		color: Color black
		yourself.
	} asShape
		scaleBy: 4;
		yourself
]

{ #category : #hooks }
YukarinAnimation >> renderIn: aCanvas [
	| frames image a b line | 
	frames := self computeFrames.

	image := RSBitmap new.
	image scaleBy: -1@1.
	aCanvas add: image.

	image form: frames first.
	image position: (0@image height/ -2).
	aCanvas newAnimation
		repeat;
		duration: 200 milliSeconds;
		when: RSAnimationLoopEvent do: [ :evt | | i |
			i := evt currentLoop % 10.
			image remove.
			image := RSBitmap new.
			image scaleBy: -1@1.
			image form: (frames at: i + 1).
			image position: (0@image height/ -2).
			aCanvas add: image.
			image pushBack.
			evt signalUpdate ].
	
	a := self newEllipse: 'A'.
	a position: -500@0.

	b := self newEllipse: 'B'.
	b position: 500@0.
	line := RSLine new
		from: a;
		to: b;
		width: 20;
		capRound;
		attachPoint: (RSBorderAttachPoint new
			startOffset: 25/2;
			endOffset: 25);
		markerEnd: (RSShapeFactory arrow
			size: 50);
		color: Color black;
		yourself.
	aCanvas addAll: { a. b. line }.
	
	aCanvas newAnimation
		delay: 0 seconds;
		easing: RSEasingInterpolator quadOut;
		duration: 10 seconds;
		from: a position;
		to: b position;
		onStepDo: [ :t | 
			image position: t+(0@image height/ -2) ].

	aCanvas when: RSExtentChangedEvent do: [ :evt | aCanvas zoomToFit ].

	
	
]

{ #category : #running }
YukarinAnimation >> run [
	<script: 'self new run'>
	self open.
	"self export."
]
