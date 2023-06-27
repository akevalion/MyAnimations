Class {
	#name : #MikuChartAnimation,
	#superclass : #RSAbstractContainerBuilder,
	#category : #'MyAnimations-Miku'
}

{ #category : #rendering }
MikuChartAnimation >> imageNamed: aString [
	| folder |
	folder := (IceRepository repositories detect: [ :each | each name = 'MyAnimations' ]) repositoryDirectory.
	^ ImageReadWriter formFromFileNamed: folder / 'img'/ aString
]

{ #category : #hooks }
MikuChartAnimation >> renderCirclesTime: t [
	| rMax rStep random color circles |
	rMax := 500.
	rStep := 5.
	circles := RSGroup new.
	color := Color white alpha: 0.8.
	random := Random seed: 1000.
	0 to: 1 do: [ :i | | r circle |
		r := rMax.
		[ r > (rMax / 10) ] whileTrue: [ | r2 angle step angleStep bigR |
			r2 := r * (i * 90 + (r/rMax*90) + t) degreesToRadians sin.
			angle := (r / rMax * 90.0 + t) degreesToRadians.
			
			circle := RSComposite new.
			circles add: circle.
			circle  matrix
				translation: (angle cos @ angle sin * r /10);
				rotateByDegrees: t /10;
				shx: (i * 90 + r2 + t) degreesToRadians cos / 2;
				shy: (i * 90 + r2 - t) degreesToRadians sin / 2 .
			step := #(2 3 4 6 8 12 16 32) atRandom: random.
			angleStep := 360 /step.
			bigR := (Float twoPi * r * angleStep ) / 360.
			angle := 0.
			
			[ angle < 360 ] whileTrue: [ | angleComposite direction linePath |
				angleComposite := RSComposite new.
				angleComposite matrix
					shx: (angle + r2 - t) degreesToRadians sin degreesToRadians * 5;
					shy: (angle + r2 + t) degreesToRadians cos degreesToRadians * 5.
				direction := random next * 2 * (random next > 0.5 ifTrue: [ -1] ifFalse: [ 1]).
				linePath := RSSVGPathLine new.
				linePath propertyAt: #radius put: r.
				linePath propertyAt: #angle put: angle.
				linePath borderColor: color.
				linePath paint: nil.
				linePath capSquare.
				linePath dashArray: { bigR / (8 / (#(1 2 3 4) atRandom: random)) }.
				linePath border dashOffset: angle + r + (t * direction).
				
				linePath width: (rMax /rStep /2)+
					(((angle*direction + r2 + (direction * t) ) degreesToRadians sin * rMax ) /
					rStep / 2).
				linePath svgPath: [ :theLine | [ :pathBuilder | | rr a |
					a := theLine propertyAt: #angle.
					rr := theLine propertyAt: #radius.
					pathBuilder
						moveTo: (a degreesToRadians cos @ a degreesToRadians sin) * rr ;
						arcCenterX: 0
						centerY: 0
						radius: rr
						startAngle: a degreesToRadians
						endAngle:  (a+ angleStep) degreesToRadians
				] ].
				
				angleComposite add: linePath.
				circle add: angleComposite.
				
				angle := angle + angleStep.
			].
			
			r := r - (rMax / rStep).
		].
	].
	^ circles
]

{ #category : #hooks }
MikuChartAnimation >> renderIn: aCanvas [

	| background miku round t |
	aCanvas color: Color black.
	background := RSBitmap new form: (self imageNamed: 'bg_main.jpg').
	background scaleBy: 1.5.
	miku := RSBitmap new form: (self imageNamed: 'miku_main.png').
	round := RSBitmap new form: (self imageNamed: 'round.png').

	aCanvas addAll: {
			background.
			round.
			miku }.
	aCanvas
		when: RSExtentChangedEvent
		do: [ :evt |
			aCanvas camera
				zoomToFit: aCanvas extent max asPoint
				rectangle: background encompassingRectangle ]
		for: self.

	aCanvas newAnimation
		repeat;
		from: 0;
		to: 360;
		duration: 15 seconds;
		onStepDo: [ :angle |
			miku position: 0 @ angle degreesToRadians sin * 100 ].
	t := 0.
	aCanvas animationFrom: {
			(aCanvas transitionAnimation
				 loops: 6 * 5;
				 duration: 10 seconds;
				 from: 0;
				 to: 360;
				 onStepDo: [ :newAngle |
					 round matrix
						 loadIdentity;
						 rotateByDegrees: newAngle.
					 aCanvas signalUpdate ]).
			(aCanvas transitionAnimation
				 duration: 10 seconds;
				 from: 0;
				 to: 360;
				 onStepDo: [ :newAngle |
					 round matrix
						 loadIdentity;
						 scaleBy: 360 - newAngle / 360.0;
						 rotateByDegrees: newAngle.
					 aCanvas signalUpdate ];
				 when: RSAnimationEndEvent do: [ round remove ] for: self;
				 yourself).
			(aCanvas transitionAnimation
				 repeat;
				 onStepDo: [
					 | circles |
					 aCanvas propertyAt: #circles ifPresent: [ :c | c do: #remove ].
					 circles := self renderCirclesTime: t.
					 aCanvas propertyAt: #circles put: circles.
					 aCanvas addAll: circles.
					 miku pushFront.
					 t := t + 1 ];
				 yourself) }
]

{ #category : #running }
MikuChartAnimation >> run [
	<script: 'self new run'>
	self open
]

{ #category : #running }
MikuChartAnimation >> runAndExport [
	<script: 'self new runAndExport'>
	self build.
	self canvas videoExporter
		duration: 12 minutes + 57 seconds;
		p1080;
		export
]
