Class {
	#name : #MikuCircleChart,
	#superclass : #RSBox,
	#instVars : [
		'time'
	],
	#category : #'MyAnimations-Miku'
}

{ #category : #visiting }
MikuCircleChart >> accept: aVisitor [
	aVisitor visitMikuCircle: self
]

{ #category : #accessing }
MikuCircleChart >> time [

	^ time
]

{ #category : #accessing }
MikuCircleChart >> time: anObject [

	time := anObject
]
