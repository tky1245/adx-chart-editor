extends Node2D
var beat: int
var bpm: float
var duration_arr: Array = [1, 4] # [x, y]: x/y of a bar; if y = 0, use x as seconds
var duration: float
var note_property_break: bool
var note_property_ex: bool
var note_property_touch: bool
var note_property_firework: bool
var note_property_both: bool
var note_position: String
var sliders: Array = []

func preview_render(current_time: float) -> void:
	note_render(current_time)
	slider_render(current_time)

func note_render(current_time: float) -> void:
	if !note_property_touch: # hold logic
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
				hexagon_shape(start_point, end_point, 18, line)
				line.self_modulate.a = intro_progress
				line.scale = Vector2(intro_progress, intro_progress)

func slider_render(current_time: float) -> void:
	for slider in $Sliders.get_children():
		slider.slider_render(current_time)

func initialize() -> void:
	if duration_arr[1] == 0:
		duration = duration_arr[0]
	else:
		duration = 60.0 * Global.beats_per_bar / bpm * (float(duration_arr[0]) / duration_arr[1])
	if !note_property_touch: # hold logic
		for node in $Note.get_children():
			node.queue_free()
		var angle = (int(note_position) * 2 - 1) * TAU / 16
		$Note.position = Global.preview_center + Global.initial_note_distance * Vector2(sin(angle), -cos(angle))
		if note_property_ex:
			var note_highlight = hexagon_shape(Vector2(0, 0), Vector2(0, 0))
			note_highlight.color = Global.note_colors["note_highlight"]
			note_highlight.width = 18
			$Note.add_child(note_highlight)
		var note_outline = hexagon_shape(Vector2(0, 0), Vector2(0, 0))
		note_outline.default_color = Color.WHITE
		note_outline.width = 11
		$Note.add_child(note_outline)
		var note_color
		if note_property_break:
			note_color = Global.note_colors["note_break"]
		elif note_property_both:
			note_color = Global.note_colors["note_both"]
		else:
			note_color = Global.note_colors["note_base"]
		var note_hold = hexagon_shape(Vector2(0, 0), Vector2(0, 0))
		note_hold.default_color = note_color
		note_hold.width = 8
		$Note.add_child(note_hold)
		
		for node in $TimelineIndicator.get_children():
			node.free()
		var new_hexagon = hexagon_shape(Vector2(0, 0), Vector2(duration * Global.timeline_pixels_to_second, 0), 4, null, 0)
		new_hexagon.default_color = note_color
		new_hexagon.width = 2
		new_hexagon.position = Vector2(0, 15 * int(note_position) - 6)
		$TimelineIndicator.add_child(new_hexagon)
		
func timeline_object_render() -> void: #TODO change visible range
	var time_1 = Global.timeline_beats[beat]
	var time_2 = time_1 + duration
	if time_2 > Global.timeline_visible_time_range["Start"] and time_1 < Global.timeline_visible_time_range["End"]:
		$TimelineIndicator.visible = true
		$TimelineIndicator.position = Vector2(Global.time_to_timeline_pos_x(time_1), 516)
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
