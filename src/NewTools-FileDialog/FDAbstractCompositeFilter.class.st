"
i define compose predicate 
	see my super class for more information
"
Class {
	#name : #FDAbstractCompositeFilter,
	#superclass : #FDAbstractFilter,
	#instVars : [
		'collectionOfFDAbstractFilter'
	],
	#category : #'NewTools-FileDialog-Filtering'
}

{ #category : #actions }
FDAbstractCompositeFilter class >> actions [
	^self allSubclasses collect: [:item |item new ]
]

{ #category : #testing }
FDAbstractCompositeFilter class >> isAbstract [ 
	^ self = FDAbstractCompositeFilter
]

{ #category : #accessing }
FDAbstractCompositeFilter >> collectionOfFDAbstractFilter [
	^ collectionOfFDAbstractFilter
]

{ #category : #accessing }
FDAbstractCompositeFilter >> collectionOfFDAbstractFilter: anObject [
	collectionOfFDAbstractFilter := anObject
]