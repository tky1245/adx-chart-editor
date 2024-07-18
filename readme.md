
this is a project of adx chart editor

still in progress tho

disclaimer: im using this to organize thought process or write notes sometimes

some known bugs:
	- touch slider bugs like: (not sure if fixed completely)
		- sliders not being rendered after slider creation using the insert slider tool
		- slider both property not being applied

todo:
	- add sounds + note hit effects
	- sound control
	- other settings like note speed
	- control to add backticks (+ check if both property works correctly on it) and firework/mines

soontm:
	- change C1 to C when exporting for adx(?)
	- optimization
	- note edit(move notes on timeline directly)
	- handle console spitting out zero length interval when things like 1-1 is declared
	- finish each note type function(mostly done):
		(hold slider implementation not done)
	- finish drawing of each note type + distinguished color storing
		(tap, hold and touch hold looks ok for now; fuck touch star)
		(firework effect missing some stars)
	- make sure everything works well
	- utils like multi select, copy pasta, bulk delete
	- utils like flip/rotate selected notes

limitations from godot:
	- clip children bug (enjoy fireworks flashing outside the preview circle for now)
	- no waveform yet cus im lazy to do further research into it
