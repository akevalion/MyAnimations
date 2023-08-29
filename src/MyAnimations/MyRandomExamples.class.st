Class {
	#name : #MyRandomExamples,
	#superclass : #Object,
	#category : #'MyAnimations-Random'
}

{ #category : #'as yet unclassified' }
MyRandomExamples >> exampleNewFeatures [

	<script: 'self new exampleNewFeatures open'>
	| canvas line x |
	canvas := RSCanvas new.
	canvas add: (RSLabel new
			 text: 'New Features';
			 color: Color white;
			 fontFamily: 'Pricedown';
			 bold;
			 yourself).
	canvas color: Color black.
	canvas @ RSCanvasController.
	line := RSLine new.
	x := 25.85.
	line controlPoints: {
			(x @ 5).
			(x @ 8) }.
	line width: 2.75.
	line color: 'white'.
	canvas add: line.
	canvas newLine
		controlPoints: {
				(x @ 6.7).
				(x + 8.5 @ 6.7) };
		color: Color white;
		width: 2.5.

	^ canvas
]
