Class {
	#name : #HexagonCellVisualization,
	#superclass : #RSAbstractContainerBuilder,
	#instVars : [
		'colors',
		'strutF',
		'rRangeF',
		'rnRangeF',
		'strutFIncre',
		'rRangeFIncre',
		'rnRangeFIncre',
		'rRange',
		'rnRange',
		'hxg',
		'initVs',
		'perlin'
	],
	#category : #'MyAnimations-Hexagon'
}

{ #category : #initialization }
HexagonCellVisualization >> initialize [
	super initialize.
	perlin := NSPerlinNoise3 new octaves: 1.
	strutF := self random: 100.
	rRangeF := self random: 100.
	rnRangeF := self random: 100.
	strutFIncre := 0.01.
	rRangeFIncre := 0.01.
	rnRangeFIncre := 0.01.
	rRange := 200.
	rnRange := Float pi / 3.0.
	hxg := MyHexagon new
		index: 6;
		level: 0;
		maxLevel: 4;
		yourself.
	initVs := (1 to: 6) collect: [ :i | 0@0 ].
]

{ #category : #initialization }
HexagonCellVisualization >> random: aNumber [
	^ SharedRandom globalGenerator next * aNumber
]

{ #category : #hooks }
HexagonCellVisualization >> renderIn: aCanvas [
	| scale position sign background |
	aCanvas color: Color gray darker.
	background := RSBox new
		extent: 2000 asPoint;
		paint: (RadialGradientPaint new
			colorRamp: { 
				0 -> Color black.
				0.75 -> Color gray darker };
			center: 0@0;
			radius: 500;
			focalPoint: 0@0;
			yourself)
		yourself.
	aCanvas newAnimation
		repeat;
		onStepDo: [ :t |
			self updateInitVs.
			hxg update:initVs strut: strutF perlin: perlin.
			
			aCanvas shapes copy do: #remove.
			aCanvas add: background.
			hxg renderIn: aCanvas.
			strutF := strutF + strutFIncre.
			 ].
	scale := 1.
	position := 0@0.
	sign := 1.
	aCanvas newAnimation
		delay: 2 seconds;
		repeat;
		onStepDo: [ :t | | value |
			value := (perlin noise: strutF * 0.7 and: 0)*0.01.
			
			scale := scale + (sign * value).
			scale > 4 ifTrue: [ sign := sign * -1 ].
			value := (perlin noise:  Time millisecondClockValue * 0.01 and: 0) * Float twoPi.
			position := scale > 2
				ifTrue: [ position "+ ((value sin @ value cos)*scale / 2) "]
				ifFalse: [ 0@0 ].
			aCanvas camera
				scale: scale;
				position: position
			 ].
		
]

{ #category : #running }
HexagonCellVisualization >> run [
	<script: 'self new run'>
	self open
	"self build.
	self canvas extent: 1920@1440.
	self canvas videoExporter
		duration: 20 seconds;
		export"
]

{ #category : #hooks }
HexagonCellVisualization >> updateInitVs [
	| rnIncre |
	rnIncre := Float pi / 3.0.
	
	initVs := initVs collectWithIndex: [ :value :index | | radius radian i |
		i := index - 1.
		radius :=  rRange + (((perlin noise: rRangeF + (i * 0.2) and: 4)) * rRange).
		radian := (rnIncre * i) + (((perlin noise: rnRangeF + (i*0.2) and: 4)-0.5) * rnRange).
		radian cos @ radian sin * radius ].
	rRangeF := rRangeF + rRangeFIncre.
	rnRangeF := rnRangeF + rnRangeFIncre
]
