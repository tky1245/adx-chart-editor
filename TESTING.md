# Testing Notes

## File I/O

### Test: Create a new chart

Steps:
1. Open the chart editor.
2. Create a new chart.
3. Select a song file.
4. Set song name.

Expected:
A fresh new chart with the selected song will be created.

Result:
Pass

---

### Test: Save and load a chart

Steps:
1. Create or open a chart.
2. Edit metadata of the chart.
3. Set BPM and divisor, then add a few notes to the chart.
4. Save the chart.
5. Return to menu/Exit the application.
6. Open the chart editor and open the chart.

Expected:
The chart will be loaded while retaining the prior edits.

Result:
Pass

---

## Chart Editor Functionality

### Test: Add notes

Steps:
1. Create or open a chart.
2. Select a note type (Tap/Hold/Slider).
3. Add the notes in.
4. Select other note types and repeat.
5. Play the chart using play button.

Expected:
The chart consisting added notes will be played.

Result:
Pass

---

### Test: Edit note position

Steps:
1. Create or open a chart.
2. Add a note of any note type (Tap/Hold/Slider).
3. Deselect the note type button.
4. Select the placed note.
5. Change note position of the note.

Expected:
The note position of the note will be changed, and it will reflect on the chart player instantly.

Result:
Pass

---

### Bug: Incorrect note selection highlight

Steps to reproduce:
1. Create or open a chart.
2. Place down a slider and edit it to be self-overlapping(like donut shaped for example).
3. Select the note.
4. Observe the note highlight.

Expected result:
The whole slider note should be properly outlined by the highlight.

Actual result:
The inner section which shouldn't be highlighted because center is hollow, is highlighted.

Status: Fixed

Verification:
Repeated the reproduction steps after the fix. The selected note was correctly highlighted.
