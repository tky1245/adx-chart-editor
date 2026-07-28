![image](https://github.com/user-attachments/assets/41b7d89b-e566-4562-a26b-713063dd240b)

ADX Chart Editor

A rhythm game chart editor developed with Godot and GDScript. The project is designed to create and edit rhythm game note charts through a visual timeline-based interface.

Current status: Functional prototype, WIP

**Features**
- Timeline-based chart editing
- Note placement and editing
- Chart saving and loading locally
- Handles multiple note types
- Audio and sound effect support
- Settings and volume controls
- Visual chart preview

**Preview**


<img width="800" height="450" alt="39c2a1fe44b5757d" src="https://github.com/user-attachments/assets/c5656611-cdba-4f1f-937e-d226f1041715" />


current hotkeys:

a/d/left/right - skip to previous/next beat
q/e - move selected note to previous/next beat
1/2/3 - select tap/hold/slider

some known bugs:
	- touch slider bugs like: (unsure if fixed completely)
		- sliders not being rendered after slider creation using the insert slider tool
		- slider selection highlight applied incorrectly
	- toggling between tap/hold makes it yellow

to-do:
	- judge arc for notes

future plans:	
	- utils like multi select, copy paste, bulk delete
	- utils like flip/rotate selected notes
	- optimization
	- auto save
	- android support
	- ios support
	- handle console spitting out zero length interval when things like 1-1 is declared
	- finish each note type:
		(hold slider implementation not done)
	

limitations from godot:
	- clip children bug (enjoy fireworks flashing outside the preview circle for now)
	- no easy way of doing waveform yet
