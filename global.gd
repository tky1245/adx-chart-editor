extends Node
var CHART_STORAGE_PATH: String = "user://Charts/"
var current_chart_name: String # song name usually
var current_chart_data: Dictionary
var root_folder: String

var CURRENT_SONG_PATH: String
var CURRENT_CHART_PATH: String
var current_difficulty: int
var note_cursor
var beat_change_cursor
var key_pressing: Array = [] # For combined keys later

# Some chart preview variables
const preview_center = Vector2(425, 250)
const preview_radius: float = 200
const preview_outcircle_radius: float = 225
var touch_positions: Dictionary
var initial_note_distance: float = 50
var note_speed_in_time = 0.4
var clicked_notes: Array[Node2D] = []
var selected_notes: Array[Node2D] = []
var current_offset: float

# for mathing and rendering
const timeline_pointer_x = 240
const timeline_leftmost_x = 116
const timeline_rightmost_x = 1080
const timeline_pixels_to_second = 240
var timeline_zoom: float = 1 # Goes from 2^-3 to 2^3
var timeline_visible_time_range: Dictionary = {"Start": 0, "End": 1}
var timeline_beats:Array = [] # arr["Beat"] = time
var timeline_beats_lines: Array = []

# Note colors
const note_colors: Dictionary = {
	# Tap/Tap hold 
	"tap_inner_base" = Color.HOT_PINK,
	"tap_inner_both" = Color.GOLD,
	"tap_inner_break" = Color.ORANGE_RED,
	"tap_outer_base" = Color.WHITE,
	"tap_outer_both" = Color.WHITE,
	"tap_outer_break" = Color.WHITE,
	"tap_highlight_ex_base" = Color(Color.PINK, 0.7),
	"tap_highlight_ex_both" = Color(Color.GOLD, 0.4),
	"tap_highlight_ex_break" = Color(Color.GOLD, 0.4),
	"tap_indicator_base" = Color.HOT_PINK,
	"tap_indicator_both" = Color.GOLD,
	"tap_indicator_break" = Color.ORANGE_RED,
	
	# Star tap/Slider star
	"star_inner_base" = Color.CORNFLOWER_BLUE,
	"star_inner_both" = Color.YELLOW,
	"star_inner_break" = Color.ORANGE_RED,
	"star_outer_base" = Color.SKY_BLUE,
	"star_outer_both" = Color.LIGHT_GOLDENROD,
	"star_outer_break" = Color.LIGHT_SALMON,
	"star_highlight_ex_base" = Color(Color.SKY_BLUE, 0.7),
	"star_highlight_ex_both" = Color(Color.YELLOW, 0.4),
	"star_highlight_ex_break" = Color(Color.YELLOW, 0.4),
	"star_indicator_base" = Color.SKY_BLUE,
	"star_indicator_both" = Color.YELLOW,
	"star_indicator_break" = Color.ORANGE_RED,
	
	# Slider arrow
	"slider_top_base" = Color.SKY_BLUE,
	"slider_top_both" = Color.YELLOW,
	"slider_top_break" = Color.ORANGE,
	"slider_bottom_both" = Color.YELLOW,
	"slider_bottom_base" = Color.SKY_BLUE,
	"slider_bottom_break" = Color.YELLOW,
	"slider_indicator_base" = Color.SKY_BLUE,
	"slider_indicator_both" = Color.YELLOW,
	"slider_indicator_break" = Color.ORANGE,
	
	# Touch
	"touch_inner_base" = Color.DODGER_BLUE,
	"touch_inner_both" = Color.SANDY_BROWN,
	"touch_inner_break" = Color.ORANGE_RED,
	"touch_outer_base" = Color.SKY_BLUE,
	"touch_outer_both" = Color.YELLOW,
	"touch_outer_break" = Color.ORANGE,
	"touch_indicator_base" = Color.SKY_BLUE,
	"touch_indicator_both" = Color.YELLOW,
	"touch_indicator_break" = Color.ORANGE_RED,
	"touch_highlight_ex_base" = Color(Color.SKY_BLUE, 0.4),
	"touch_highlight_ex_both" = Color(Color.YELLOW, 0.4),
	"touch_highlight_ex_break" = Color(Color.YELLOW, 0.4),
	
	# Touch hold
	"touch_hold_1" = Color.RED,
	"touch_hold_2" = Color.YELLOW,
	"touch_hold_3" = Color.SEA_GREEN,
	"touch_hold_4" = Color.ROYAL_BLUE,
	"touch_hold_center" = Color.CYAN,
}

# Some settings
var beats_per_bar = 4
var background_dim: float = 0.5

func time_to_timeline_pos_x(time): # convert time to pos_x on timeline
	var pos_x = timeline_leftmost_x + (timeline_rightmost_x - timeline_leftmost_x) / (timeline_visible_time_range["End"] - timeline_visible_time_range["Start"]) * (time - timeline_visible_time_range["Start"])
	return pos_x

func _ready():
	# android stuffs
	root_folder = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	if OS.has_feature("android"):
		CHART_STORAGE_PATH = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/ADXChartViewer/Charts"
		var dir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP))
		dir.make_dir("ADXChartViewer")
		dir.change_dir("ADXChartViewer")
		dir.make_dir("Charts")
	# Generate touch positions
	for i in range(8):
		var pos_name = "A" + str(i + 1)
		var distance = 168.0
		var angle = PI / 8 * (1 + i * 2)
		var pos = Vector2(Vector2(distance * sin(angle), distance * -cos(angle)))
		touch_positions[pos_name] = pos
	for i in range(8):
		var pos_name = "B" + str(i + 1)
		var distance = 91.0
		var angle = PI / 8 * (1 + i * 2)
		var pos = Vector2(Vector2(distance * sin(angle), distance * -cos(angle)))
		touch_positions[pos_name] = pos
	for i in range(8):
		var pos_name = "C" + str(i + 1)
		var pos = Vector2(0, 0)
		touch_positions[pos_name] = pos
	for i in range(8):
		var pos_name = "D" + str(i + 1)
		var distance = 180.0
		var angle = PI / 4 * i
		var pos = Vector2(distance * sin(angle), distance * -cos(angle))
		touch_positions[pos_name] = pos
	for i in range(8):
		var pos_name = "E" + str(i + 1)
		var distance = 128.0
		var angle = PI / 4 * i
		var pos = Vector2(distance * sin(angle), distance * -cos(angle))
		touch_positions[pos_name] = pos
	for i in range(8):
		var pos_name = str(i + 1)
		var distance = preview_radius
		var angle = PI / 8 * (1 + i * 2)
		var pos = Vector2(Vector2(distance * sin(angle), distance * -cos(angle)))
		touch_positions[pos_name] = pos
		

func note_pos_mod(num: int):
	return (num - 1) % 8 + 1

func touch_position_angle(note_position: String):
	var txt_left = note_position.left(-1)
	var txt_right = note_position.right(1)
	var angle: float
	if txt_left in ["", "A", "B", "C"]:
		angle = PI / 8 * (1 + (int(txt_right)) * 2) - 3*TAU/8
	elif txt_left in ["D", "E"]:
		angle = PI / 4 * int(txt_right) - 3*TAU/8
	while angle < 0:
		angle += TAU
	return angle
