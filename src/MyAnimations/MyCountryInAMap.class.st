Class {
	#name : #MyCountryInAMap,
	#superclass : #Object,
	#category : #'MyAnimations-BoliviaQ'
}

{ #category : #running }
MyCountryInAMap >> run [
	<script: 'self new run'>
	| b canvas boliviaLocation position form paint |
	b := RSOSMBuilder new.
	b build.
	boliviaLocation := -25.274399 @ 133.775131.
	b latLong: boliviaLocation.
	form := MikuChartAnimation new imageNamed: 'mil.png'.
	position := b latLogToRoassalCoordinates: boliviaLocation.
	paint := AthensCairoPatternSurfacePaint createForSurface:
		         (AthensCairoSurface fromForm: form).
	paint origin: (form extent / 2) negated.
	canvas := b canvas.
	
	canvas add: (RSEllipse new
		paint: paint;
		position: position + (0 @ -150);
		scaleBy: 5;
		size: form width).
	^ canvas inspect
]
