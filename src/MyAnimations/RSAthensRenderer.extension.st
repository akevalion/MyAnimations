Extension { #name : #RSAthensRenderer }

{ #category : #'*MyAnimations' }
RSAthensRenderer >> visitMikuCircle: miku [
	| rMax rStep t random color stroke |
	t := miku time.
	rMax := 300.
	rStep := 5.
	color := Color white translucent.
	random := SharedRandom globalGenerator.
	
	"low level code need it to draw crazy things"
	0 to: 1 do: [ :i | | r |
		r := rMax.
		[ r > (rMax / 10) ] whileTrue: [ | r2 |
			r2 := r * (i * 90 + ((r/rMax)*90) +t) degreesToRadians sin.
			athensCanvas pathTransform restoreAfter: [ | angle step angleStep bigR |
				
				angle := (r / rMax * 90 + t) degreesToRadians.
				athensCanvas pathTransform
					translateX: (angle cos * r)/10 Y: (angle sin * r)/10;
					rotateByDegrees: t / 10;
					shx: (i * 90 + r2 + t) degreesToRadians cos * 5;
					shy: (i * 90 + r2 - t) degreesToRadians sin * 5.
				step := #(2 3 4 6 8 12 16 32) atRandom.
				angleStep := 360 /step.
				bigR := (Float twoPi * r * angleStep ) / 360.
				angle := 0.
				[ angle < 360 ] whileTrue: [
					athensCanvas pathTransform restoreAfter: [ | direction path |
						
						athensCanvas pathTransform
							shx: (angle + r2 - t) degreesToRadians sin * 5;
							shy: (angle + r2 + t) degreesToRadians cos * 5.
						direction := random next * 2 * (random next > 0.5 ifTrue: [ -1] ifFalse: [ 1]).
						
						athensCanvas setPathMatrix.
						path := athensCanvas createPath: [ :pathBuilder | 
							pathBuilder
								arcCenterX: 0
								centerY: 0
								radius: r * 2
								startAngle: angle degreesToRadians
								endAngle:  (angle+ angleStep) degreesToRadians
							 ].
						athensCanvas setShape: path.
						
						stroke := (color asAthensPaintOn: athensCanvas) asStrokePaintOn: athensCanvas.
						stroke capSquare.
						stroke 
							dashes: { bigR / 8 / #(1 2 3 4) atRandom }
							offset: angle + r + (t * direction).
						stroke width: (rMax /rStep /2)+
						((rMax * (angle*direction + r2 + (direction * t) ) sin) /
						rStep / 2).
						
						athensCanvas draw.
					].
					angle := angle + angleStep.
				 ]
			].
			
			r := r - (rMax / rStep).
		].
	].
	
]
