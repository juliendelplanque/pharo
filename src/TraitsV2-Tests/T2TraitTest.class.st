"
Unit test for trait handling
"
Class {
	#name : #T2TraitTest,
	#superclass : #T2AbstractTest,
	#category : #'TraitsV2-Tests-Tests'
}

{ #category : #tests }
T2TraitTest >> createT1 [
	| t1 |
	t1 := self newTrait: #T1 with: 'a b c' asSlotCollection.
	t1
		compile:
			'setValues
		a := 1.
		b := 2.
		c := 3.
	'.
	t1
		compile:
			'getValues
		^ a + b + c
	'.
	^ t1
]

{ #category : #tests }
T2TraitTest >> createT2 [
	| t2 |
	t2 := self newTrait: #T2 with: 'd e f' asSlotCollection.
	t2
		compile:
			'setValues2
		d := 1.
		e := 2.
		f := 3.
	'.
	t2
		compile:
			'getValues2
		^ d + e + f + self getValues
	'.
	^ t2
]

{ #category : #tests }
T2TraitTest >> testClassTraits [
	| t1 t2 aClass |

	t1 := self newTrait: #T1 with: #().
	t2 := self newTrait: #T2 with: #().

	t1 classTrait compile: 'aSelector ^ 21'.
	t1 classTrait compile: 'otherSelector ^ 42'.
	
	t2 classTrait compile: 'otherSelector2 ^ 42'.

	aClass := self newClass: #C1 superclass: Object with: #() uses: {}.
	aClass class setTraitComposition: t1 classSide - { #aSelector }. 
	
	self assert: aClass otherSelector equals: 42.	

	aClass := self newClass: #C1 superclass: Object with: #() uses: {}.
	aClass class setTraitComposition: t1 classSide + t2 classSide. 
	
	self assert: aClass otherSelector equals: 42.
	self assert: aClass otherSelector2 equals: 42.
	self assert: aClass aSelector equals: 21.
	

	aClass := self newClass: #C1 superclass: Object with: #() uses: {}.
	aClass class setTraitComposition: t1 classSide @ {#anAlias -> #aSelector}. 
	
	self assert: aClass anAlias equals: 21.
	self assert: aClass aSelector equals: 21.
]

{ #category : #tests }
T2TraitTest >> testIndirectSequence [
	| t1 t2 t3 c1 obj |
	
	t1 := self createT1.
	t2 := self createT2.
	t3 := self newTrait: #T3 with: #() uses: t1 + t2.
		
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t3.

	obj := c1 new.
	obj setValues.
	obj setValues2.
	
	self assert: (TraitedClass basicUsers includesAll:  { t1 class. t2 class. t3 class. c1 class}).
	
	self assert: obj getValues equals: 6.
	self assert: obj getValues2 equals: 12
]

{ #category : #tests }
T2TraitTest >> testMethodsAddedInMetaclass [
	| t1 c1 |
	
	t1 := self createT1.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	
	self assertCollection: c1 class selectors sorted equals: TraitedClass selectors sorted.

]

{ #category : #tests }
T2TraitTest >> testMethodsAddedInMetaclassNotPresentInSubclasses [
	| t1 c1 c2 |
	
	t1 := self createT1.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	c2 := self newClass: #C2 superclass: c1 with: #() uses: {}.
	
	self assertCollection: c2 class selectors sorted equals: #().

]

{ #category : #tests }
T2TraitTest >> testMethodsAddedInMetaclassPresentInSubclassesAfterChangingSuperclass [
	| t1 c1 c2 t2 |
	
	t1 := self createT1.
	t2 := self createT2.
	
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	c2 := self newClass: #C2 superclass: c1 with: #() uses: {t2}.
	
	self assertCollection: c2 class selectors sorted equals: #().
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: {}.

	"When a class that uses traits has a empty traitComposition it still keeps being a TraitedClass"
	self assertCollection: c2 class selectors sorted equals: #().

]

{ #category : #tests }
T2TraitTest >> testMethodsAddedInMetaclassPresentInSubclassesAfterRemovingSuperclass [
	| t1 c1 c2 t2 |
	
	t1 := self createT1.
	t2 := self createT2.
	
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	c2 := self newClass: #C2 superclass: c1 with: #() uses: {t2}.
	
	self assertCollection: c2 class selectors sorted equals: #().
	c1 removeFromSystem.

	self assertCollection: c2 class selectors sorted equals: TraitedClass selectors sorted.

]

{ #category : #tests }
T2TraitTest >> testSelectorsWithExplicitOrigin [
	"Obtain the subset of selectors that are defined either locally or inherited from traits. But, exclude selectors of methods from implicit traits such as TraitedClass"
	| t1 c1 |
	
	t1 := self newTrait: #T1 with: #().	
	t1 compile: 'instanceSideMethod'.
	t1 class compile: 'classSideMethod'.
	c1 := self newClass: #C1 with: #() uses: t1.
	self assertCollection: c1 selectorsWithExplicitOrigin hasSameElements: #(instanceSideMethod).
	self assertCollection: c1 class selectorsWithExplicitOrigin hasSameElements: #(classSideMethod).

]

{ #category : #tests }
T2TraitTest >> testSelectorsWithExplicitOriginNoTrait [
	"Obtain the subset of selectors that are defined either locally or inherited from traits. But, exclude selectors of methods from implicit traits such as TraitedClass"
	| c1 |	
	c1 := self newClass: #C1.
	c1 compile: 'instanceSideMethod'.
	c1 class compile: 'classSideMethod'.
	self assertCollection: c1 selectorsWithExplicitOrigin hasSameElements: #(instanceSideMethod).
	self assertCollection: c1 class selectorsWithExplicitOrigin hasSameElements: #(classSideMethod).

]

{ #category : #tests }
T2TraitTest >> testSequence [
	| t1 t2 c1 obj |
	
	t1 := self createT1.
	t2 := self createT2.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1 + t2.

	obj := c1 new.
	obj setValues.
	obj setValues2.
	
	
	self assert: (TraitedClass basicUsers includesAll:  { t1 class. t2 class. c1 class}).
	
	self assert: obj getValues equals: 6.
	self assert: obj getValues2 equals: 12
]
