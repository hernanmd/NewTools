"
The Settings Browser it is organized in three main Spec presenters:

- A toolbar which holds operations to be performed (mainly searching), presented by `StSettingsToolbarPresenter`.
- A presenter for ""main categories"", presented by `StSettingsCategoriesPresenter`.
- And a ""details presenter"", presented by `StSettingsPagePresenter`, instantiated when the users selects a main category.
"
Class {
	#name : 'StSettingsMainPresenter',
	#superclass : 'StSettingsAbstractPresenter',
	#instVars : [
		'toolbarPresenter',
		'detailsPresenter',
		'mainCategoriesPresenter',
		'buttonBarPresenter'
	],
	#category : 'NewTools-SettingsBrowser-UI',
	#package : 'NewTools-SettingsBrowser',
	#tag : 'UI'
}

{ #category : 'initialization' }
StSettingsMainPresenter >> browserTitle [ 

	^ 'Settings Browser'
]

{ #category : 'initialization' }
StSettingsMainPresenter >> connectPresenters [ 

	mainCategoriesPresenter 
		transmitTo: detailsPresenter
		transform: [ : aCategoryItemPresenter | aCategoryItemPresenter node ]
]

{ #category : 'layout' }
StSettingsMainPresenter >> defaultInputPort [ 

	^ SpListItemsPort newPresenter: detailsPresenter

]

{ #category : 'layout' }
StSettingsMainPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		spacing: 5;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 0.2;
				   add: (SpBoxLayout newTopToBottom
						    add: toolbarPresenter withConstraints: [ :constraints |
							    constraints
								    height: self class toolbarHeight + 10;
								    padding: 5 ];
						    add: mainCategoriesPresenter;
						    yourself);
				   add: detailsPresenter);
		  add: buttonBarPresenter expand: false;
		  yourself
]

{ #category : 'ports' }
StSettingsMainPresenter >> defaultOutputPort [ 

	^ mainCategoriesPresenter
]

{ #category : 'export' }
StSettingsMainPresenter >> exportAllSettings: actions by: groupSize withBasename: aString [
	"Export all settings in files. No more than groupSize settings will be exported to the same file. If there are more than groupSize settings, settings will be exported in multiple files (named aString%d.st, with %d a number increasing from 1 to (actions size / groupSize)."
	| index outputFilename |
	
	index := 1.
	outputFilename := aString , index printString , '.st'.

	actions
		groupsOf: groupSize
		atATimeDo: [ :setting |
			self exportSettings: setting toFileNamed: aString , index printString , '.st'.
			index := index + 1 ].
	self
		exportSettings: (actions last: (actions size rem: groupSize))
		toFileNamed: outputFilename.
		
	self inform: 'Settings exported to ' , (StartupPreferencesLoader preferencesGeneralFolder / outputFilename) fullName.
]

{ #category : 'export' }
StSettingsMainPresenter >> exportSettings [
	| nodes actions   |

	nodes := self settingsTree nodeList.
	actions := nodes 
		collect: [ : e | e item exportSettingAction ]
		thenReject: [ : e | e isNil ].
	self 
		exportAllSettings: actions 
		by: 50 
		withBasename: 'exported_settings'.
	
	buttonBarPresenter enable
]

{ #category : 'export' }
StSettingsMainPresenter >> exportSettings: aCollection toFileNamed: filename [

	StartupPreferencesLoader default
		addAtStartupInPreferenceVersionFolder: aCollection
		named: filename
]

{ #category : 'initialization' }
StSettingsMainPresenter >> initializeButtonBar [

	buttonBarPresenter := self newButtonBar
		placeAtEnd;
		add: (self newButton
			addStyle: 'large';
			icon: (self iconNamed: #openFromUrl);
			label: 'Load';
			help: 'Load settings from a file';
			action: [ self loadSettings ];
			enabled: self settingsTree hasSettingsFile;
			yourself);
		add: (self newButton
			icon: (self application iconNamed: #save);
			label: 'Export';
			help: 'Save settings into a file';
			action: [ self exportSettings ];
			yourself);
		add: (self newButton
			icon: (self iconNamed: #cancel);
			action: [ self delete ];
			label: 'Cancel';
			yourself).
]

{ #category : 'initialization' }
StSettingsMainPresenter >> initializeFocus [

	self focusOrder 
		add: toolbarPresenter;
		add: mainCategoriesPresenter;
		add: detailsPresenter
]

{ #category : 'initialization' }
StSettingsMainPresenter >> initializePresenters [

	toolbarPresenter := self instantiate: StSettingsToolbarPresenter on: self.
	mainCategoriesPresenter := self instantiate: StSettingsCategoriesPresenter on: self.
	detailsPresenter := self instantiate: StSettingsPagePresenter on: self.
	self initializeButtonBar.
	
	self initializeFocus.
]

{ #category : 'initialization' }
StSettingsMainPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: self browserTitle;
		initialExtent: 1200 @ 700;
		centered
]

{ #category : 'menu' }
StSettingsMainPresenter >> loadSettings [
	"Load the settings from the system settings file, if exists"

	self settingsTree hasSettingsFile
		ifTrue: [ self settingsTree updateSettingNodes ]
]
