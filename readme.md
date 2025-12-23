![image](https://github.com/user-attachments/assets/41b7d89b-e566-4562-a26b-713063dd240b)


this is a project of adx chart editor

still in progress tho

disclaimer: im using this to organize thought process or write notes sometimes

current hotkeys:

a/d/left/right - skip to previous/next beat

q/e - move selected note to previous/next beat

1/2/3 - select tap/hold/slider


some known bugs:
	- touch slider bugs like: (not sure if fixed completely)
		- sliders not being rendered after slider creation using the insert slider tool
		- slider selection highlight applied incorrectly
	- toggling between tap/hold makes it yellow

todo:
	- judge arc for notes

soontm:	
	- utils like multi select, copy pasta, bulk delete
	- utils like flip/rotate selected notes
	- optimization
	- auto save
	- android support (zzz)
	- ios support(i dont have an ios to test)
	- handle console spitting out zero length interval when things like 1-1 is declared
	- finish each note type:
		(hold slider implementation not done)
	

limitations from godot:
	- clip children bug (enjoy fireworks flashing outside the preview circle for now)
	- no waveform yet cus im lazy to do further research into it
