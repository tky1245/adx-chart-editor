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


How to use:
1) Select new chart then pick a music file
2) Set chart metadata such as difficulty, chart level number and more
3) Set BPM and Beat Divisor using the buttons (180 BPM and 4 Divisor for example)
4) Select a note type and click on the playing area, a new note will be added to where the timeline indicator is at
5) If note type is slider, the quick way to put sliders is to click start position then click mid/end position; 1 then 5 to make a straight line from 1 to 5, clicking 7 again after this will make a slider going from 1 to 5 to 7. Select any note type again to exit slider chaining mode.
6) Break, EX, Touch toggle buttons will affect the newly placed note.
7) Select the same note type again to deselect it, and when nothing is selected you can click an existing note to select and edit the note.
8) Note properties are on the right side of note placing buttons. Simply edit to make changes to the selected note.
9) Use Play/Stop buttons to control chart player, and dragging progress bar/timeline can move the timeline. Alternatively use hotkeys to move timeline snapping to previous/next beat
10) **Options -> Save** to save any changes made to the chart. There isn't an autosave feature so make sure to save often.
11) **Options -> Export to maidata** exports the chart into a folder containing the chart. You can then play the chart on another chart player such as AstroDX or MajdataPlay.

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
