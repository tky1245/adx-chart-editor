extends Node
var CURRENT_SONG_PATH: String
var CURRENT_CHART_PATH: String
var current_difficulty: int
var note_cursor
var beat_change_cursor
const preview_center = Vector2(425, 250)
const preview_radius = 200
var touch_positions: Dictionary
var initial_note_distance = 150

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

func _ready():
	# Generate touch positions
	for i in range(8):
		var pos_name = "A" + str(i + 1)
		var distance = 168.0
		var angle = PI / 8 * (1 + i * 2)
		var pos = Vector2(preview_center + Vector2(distance * sin(angle), distance * cos(angle)))
		touch_positions[pos_name] = pos
	for i in range(8):
		var pos_name = "B" + str(i + 1)
		var distance = 91.0
		var angle = PI / 8 * (1 + i * 2)
		var pos = Vector2(preview_center + Vector2(distance * sin(angle), distance * cos(angle)))
		touch_positions[pos_name] = pos
	touch_positions["C"] = preview_center
	for i in range(8):
		var pos_name = "D" + str(i + 1)
		var distance = 180.0
		var angle = PI / 4 * i
		var pos = Vector2(preview_center + Vector2(distance * sin(angle), distance * cos(angle)))
		touch_positions[pos_name] = pos
	for i in range(8):
		var pos_name = "E" + str(i + 1)
		var distance = 128.0
		var angle = PI / 4 * i
		var pos = Vector2(preview_center + Vector2(distance * sin(angle), distance * cos(angle)))
		touch_positions[pos_name] = pos
