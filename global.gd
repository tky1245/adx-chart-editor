extends Node
var CURRENT_SONG_PATH: String
var CURRENT_CHART_PATH: String
var current_difficulty: int
var note_cursor
var beat_change_cursor

# for mathing and rendering
const timeline_pointer_x = 240
const timeline_leftmost_x = 116
const timeline_rightmost_x = 1080
const timeline_pixels_to_second = 240
var timeline_zoom: float = 1 # Goes from 2^-3 to 2^3
var timeline_visible_time_range: Dictionary = {"Start": 0, "End": 1}
var timeline_beats:Array = [] # arr["Beat"] = time
var timeline_beats_lines: Array = []

func time_to_timeline_pos_x(time): # convert time to pos_x on timeline
	if time <= timeline_visible_time_range["End"] and time >= timeline_visible_time_range["Start"]:
		var pos_x = timeline_leftmost_x + (timeline_rightmost_x - timeline_leftmost_x) / (timeline_visible_time_range["End"] - timeline_visible_time_range["Start"]) * (time - timeline_visible_time_range["Start"])
		return pos_x
	else:
		return 0
