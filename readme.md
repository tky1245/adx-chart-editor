
this is a project of adx chart editor

still in progress tho

disclaimer: im using this to organize thought process or write notes sometimes

note placement optiomization thoughts:
	- tap/touch/hold placing: click "tap" -> consecutive placements 
	- hold/slider: remembers the most recent used duration to place them faster
	- 

some known bugs:
	- hold toggle causing result note to not have correct properties
	- delay became negative after loading a chart?

todo:
	- improve adding slider convenience
	- add sounds + note effects
	- make firework function

soontm:
	- optimization (its a bit laggy rn)
	- sound control
	- control to add backticks (+ check if both property works correctly on it)
	- note edit(move notes on timeline directly)
	- handle console spitting out zero length interval when things like 1-1 is declared
	- finish each note type function(mostly done):
		(hold slider implementation not done)
	- finish drawing of each note type + distinguished color storing
		(tap, hold and touch hold looks ok for now; fuck touch star)
		(ex star hightlight redo)
		(there are a bit of hollow within star's lines?)
	- make sure everything works well
	- utils like multi select, copy pasta, bulk delete
	- utils like flip/rotate selected notes
