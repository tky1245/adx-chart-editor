extends Node2D
var type = Note.type.TAP_HOLD
var beat: int = 0
var bpm: float = 0.0
var duration_arr: Array = [1, 4] # [x, y]: x/y of a bar; if y = 0, use x as seconds
var duration: float = 0.0
var note_property_break: bool = false
var note_property_ex: bool = false
var note_property_firework: bool = false
var note_property_both: bool = false
var note_position: String = ""
var sliders: Array = []

var selected: bool = false

func preview_render(current_time: float) -> void:
	note_render(current_time)
	slider_render(current_time)

func note_render(current_time: float) -> void:
	var angle = (int(note_position) * 2 - 1) * TAU / 16
	
	var intro_time = Global.timeline_beats[beat] - Global.note_speed_in_time
	var move_time_start_point = Global.timeline_beats[beat] - Global.note_speed_in_time * 0.7
	var judge_time_start_point = Global.timeline_beats[beat]
	var move_time_end_point = Global.timeline_beats[beat] + duration - Global.note_speed_in_time * 0.7
	var judge_time_end_point = Global.timeline_beats[beat] + duration
	
	var intro_progress: float
	var start_progress: float
	var end_progress: float
	
	if current_time < intro_time:
		$Note.visible = false
		intro_progress = 0
		start_progress = 0
		end_progress = 0
	elif current_time < move_time_start_point:
		$Note.visible = true
		intro_progress = (current_time - intro_time) / (move_time_start_point - intro_time)
		start_progress = 0
		end_progress = 0
	elif current_time >= judge_time_end_point:
		$Note.visible = false
		intro_progress = 1
		start_progress = 1
		end_progress = 1
	else:
		$Note.visible = true
		intro_progress = 1
		if current_time < judge_time_start_point:
			start_progress = (current_time - move_time_start_point) / (judge_time_start_point - move_time_start_point)
		else:
			start_progress = 1
		if current_time < move_time_end_point:
			end_progress = 0
		elif current_time < judge_time_end_point:
			end_progress = (current_time - move_time_end_point) / (judge_time_end_point - move_time_end_point)
		else:
			end_progress = 1
	
	var start_point = Vector2(sin(angle), -cos(angle)) * (Global.preview_radius - Global.initial_note_distance) * start_progress
	var end_point = Vector2(sin(angle), -cos(angle)) * (Global.preview_radius - Global.initial_note_distance) * end_progress
	for line in $Note.get_children():
			var radius = 18 if line.name != "SelectedHighlight" else 32
			hexagon_shape(start_point, end_point, radius, line)
			line.self_modulate.a = intro_progress
			line.scale = Vector2(intro_progress, intro_progress)

func slider_render(current_time: float) -> void:
	for slider in $Sliders.get_children():
		slider.slider_render(current_time)

func initialize() -> void:
	set_duration()
	set_note_position()
	tap_hold_draw()
	for slider in sliders: #soontm
		pass
	set_selected()

func note_draw() -> void:
	tap_hold_draw()

func tap_hold_draw() -> void:
	# Colors
	var note_color_outer
	var note_color_inner
	var note_color_highlight_ex

	if note_property_break:
		note_color_outer = Global.note_colors["tap_outer_break"]
		note_color_inner = Global.note_colors["tap_inner_break"]
		note_color_highlight_ex = Global.note_colors["tap_highlight_ex_break"]
	elif note_property_both:
		note_color_outer = Global.note_colors["tap_outer_both"]
		note_color_inner = Global.note_colors["tap_inner_both"]
		note_color_highlight_ex = Global.note_colors["tap_highlight_ex_both"]
	else:
		note_color_outer = Global.note_colors["tap_outer_base"]
		note_color_inner = Global.note_colors["tap_inner_base"]
		note_color_highlight_ex = Global.note_colors["tap_highlight_ex_base"]
	
	# Tap hold
	for node in $Note.get_children():
		if node.name != "SelectedHighlight":
			node.queue_free()
	if note_property_ex:
		var note_highlight = hexagon_shape(Vector2(0, 0), Vector2(0, 0))
		note_highlight.default_color = note_color_highlight_ex
		note_highlight.width = 18
		$Note.add_child(note_highlight)
	var note_outline = hexagon_shape(Vector2(0, 0), Vector2(0, 0))
	note_outline.default_color = Color.WHITE
	note_outline.width = 11
	$Note.add_child(note_outline)
	var note_hold = hexagon_shape(Vector2(0, 0), Vector2(0, 0))
	note_hold.default_color = note_color_inner
	note_hold.width = 8
	$Note.add_child(note_hold)
	
	var selected_highlight = $Note/SelectedHighlight
	selected_highlight.points = hexagon_shape(Vector2(0, 0), Vector2(0, 0), 32).points
	selected_highlight.default_color = Color.LIME
	
	timeline_object_draw()

func timeline_object_draw() -> void:
	var note_color_timeline_indicator
	if note_property_break:
		note_color_timeline_indicator = Global.note_colors["tap_indicator_break"]
	elif note_property_both:
		note_color_timeline_indicator = Global.note_colors["tap_indicator_both"]
	else:
		note_color_timeline_indicator = Global.note_colors["tap_indicator_base"]
	
	for node in $TimelineIndicator.get_children():
		node.free()
	var new_hexagon = hexagon_shape(Vector2(0, 0), Vector2(duration * Global.timeline_pixels_to_second * Global.timeline_zoom, 0), 4, null, 0)
	new_hexagon.default_color = note_color_timeline_indicator
	new_hexagon.width = 2
	$TimelineIndicator.position = Vector2(0, 15 * int(note_position) + 510)
	$TimelineIndicator.add_child(new_hexagon)
	var indicator_highlight = Line2D.new()
	var poly = Geometry2D.offset_polygon(hexagon_shape(Vector2(0, 0), Vector2(duration * Global.timeline_pixels_to_second * Global.timeline_zoom, 0), 4, null, 0).points, 4)[0]
	indicator_highlight.name = "IndicatorHighlight"
	indicator_highlight.points = poly
	indicator_highlight.closed = true
	indicator_highlight.default_color = Color.LIME
	indicator_highlight.width = 2
	$TimelineIndicator.add_child(indicator_highlight)
	
	for slider in $Sliders.get_children():
		slider.timeline_object_draw()

func set_note_position(pos: String = note_position) -> void:
	note_position = pos

	var angle = (int(note_position) * 2 - 1) * TAU / 16
	$Note.position = Global.preview_center + Global.initial_note_distance * Vector2(sin(angle), -cos(angle))
	for slider in $Sliders.get_children():
		slider.initialize($Note.position - Global.preview_center)
	
func set_duration(arr: Array = duration_arr) -> void:
	duration_arr = arr
	if duration_arr[1] == 0:
		duration = duration_arr[0]
	else:
		duration = 60.0 * Global.beats_per_bar / bpm * (float(duration_arr[0]) / duration_arr[1])

func timeline_object_render() -> void: #TODO change visible range
	var time_1 = Global.timeline_beats[beat]
	var time_2 = time_1 + duration
	if time_2 > Global.timeline_visible_time_range["Start"] and time_1 < Global.timeline_visible_time_range["End"]:
		$TimelineIndicator.visible = true
		$TimelineIndicator.position.x = Global.time_to_timeline_pos_x(time_1)
	else:
		$TimelineIndicator.visible = false

func hexagon_shape(point_1: Vector2, point_2: Vector2, radius: float = 18, hexagon: Line2D = null, angle: float = ((int(note_position) * 2 - 1) * TAU / 16) + TAU / 4) -> Line2D:
	if !hexagon:
		var new_line = Line2D.new()
		new_line.closed = true
		new_line.add_point(point_1 + Vector2(-radius, 0).rotated(angle - TAU / 6))
		new_line.add_point(point_1 + Vector2(-radius, 0).rotated(angle))
		new_line.add_point(point_1 + Vector2(-radius, 0).rotated(angle + TAU / 6))
		new_line.add_point(point_2 + Vector2(-radius, 0).rotated(angle + 2 * TAU / 6))
		new_line.add_point(point_2 + Vector2(-radius, 0).rotated(angle + 3 * TAU / 6))
		new_line.add_point(point_2 + Vector2(-radius, 0).rotated(angle + 4 * TAU / 6))
		return new_line
	else:
		hexagon.set_point_position(0, point_1 + Vector2(-radius, 0).rotated(angle - TAU / 6))
		hexagon.set_point_position(1, point_1 + Vector2(-radius, 0).rotated(angle))
		hexagon.set_point_position(2, point_1 + Vector2(-radius, 0).rotated(angle + TAU / 6))
		hexagon.set_point_position(3, point_2 + Vector2(radius, 0).rotated(angle - TAU / 6))
		hexagon.set_point_position(4, point_2 + Vector2(radius, 0).rotated(angle))
		hexagon.set_point_position(5, point_2 + Vector2(radius, 0).rotated(angle + TAU / 6))
		return hexagon

func set_selected(option: bool = selected):
	selected = option
	$Note/SelectedHighlight.visible = selected
	$TimelineIndicator/IndicatorHighlight.visible = selected
	for slider_node in $Sliders.get_children():
		slider_node.set_selected(selected)

func select_area() -> Array:
	var arr: Array = []
	if $Note.visible:
		var note_selected_highlight = $Note.get_child($Note.get_child_count()-1)
		arr.append(note_selected_highlight.points * Transform2D(0.0, -note_selected_highlight.global_position))
	if $TimelineIndicator.visible:
		var indicator_highlight = $TimelineIndicator/IndicatorHighlight
		arr.append(indicator_highlight.points * Transform2D(0.0, -indicator_highlight.global_position))
	for slider in $Sliders.get_children():
		arr.append_array(slider.select_area())
	return arr

func get_args() -> Dictionary:
	var new_dict: Dictionary = {
	"beat": beat,
	"bpm": bpm,
	"duration_arr": duration_arr,
	"duration": duration,
	"note_property_break": note_property_break,
	"note_property_ex": note_property_ex,
	"note_property_firework": note_property_firework,
	"note_property_both": note_property_both,
	"note_position": note_position,
	"sliders": sliders,
	"selected": selected,
	}
	return new_dict
