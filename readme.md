
this is a project of adx chart editor

still in progress tho

disclaimer: im using this to organize thought process or write notes sometimes

some known bugs:
	- touch slider bugs like: (not sure if fixed completely)
		- sliders not being rendered after slider creation using the insert slider tool
		- slider selection highlight applied incorrectly

todo:
	- judge arc for notes
	- note edit(move notes on timeline directly; add beat or delete beat somewhere in the chart)

soontm:	
	- utils like multi select, copy pasta, bulk delete
	- utils like flip/rotate selected notes
	- optimization
	- android support
	- ios support(i dont have an ios to test)
	- handle console spitting out zero length interval when things like 1-1 is declared
	- finish each note type:
		(hold slider implementation not done)
	- finish drawing of each note type + distinguished color storing
		(tap, hold and touch hold looks ok for now; fuck touch star)
		(firework effect missing some stars)
	

limitations from godot:
	- clip children bug (enjoy fireworks flashing outside the preview circle for now)
	- no waveform yet cus im lazy to do further research into it
