Class {
	#name : #CreateHexagon,
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
	#category : #MyAnimations
}

{ #category : #initialization }
CreateHexagon >> initialize [
	super initialize.
	perlin := NSPerlinNoise3 new octaves: 3.
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
		maxLevel: 3;
		yourself.
	initVs := (1 to: 6) collect: [ :i | 0@0 ].
]

{ #category : #initialization }
CreateHexagon >> random: aNumber [
	^ SharedRandom globalGenerator next * aNumber
]

{ #category : #hooks }
CreateHexagon >> renderIn: aCanvas [
	aCanvas newAnimation
		repeat;
		onStepDo: [ :t |
			self updateInitVs.
			aCanvas shapes size traceCr.
			hxg update:initVs strut: strutF perlin: perlin.
			aCanvas shapes copy do: #remove.
			hxg renderIn: aCanvas.
			strutF := strutF + strutFIncre.
			aCanvas zoomToFit.
			 ].
]

{ #category : #running }
CreateHexagon >> run [
	<script: 'self new run'>
	self build.
	self canvas extent: 720@720.
	self canvas videoExporter
		duration: 10 seconds;
		export
]

{ #category : #hooks }
CreateHexagon >> updateInitVs [
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
