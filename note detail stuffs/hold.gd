extends Node2D
var beat: int
var bpm: float
var duration_x: float # duration = x/y of a bar
var duration_y: int
var note_property_break: bool
var note_property_ex: bool
var note_property_touch: bool
var note_property_firework: bool
var note_property_both: bool
var note_position: String

func preview_render(current_time: float) -> void:
	var item1 = $Preview/NoteShape.get_child(0)
	var item2 = $Preview/NoteShape.get_child(1)
	var preview = $Preview
	var noteshape = $Preview/NoteShape
	if note_property_touch: # touch hold logic
		pass
	else: # hold logic
		var angle = (int(note_position) * 2 - 1) * TAU / 16
		var start_progress
		var end_progress
		var start_point = Vector2(sin(angle), -cos(angle)) * (Global.preview_radius - Global.initial_note_distance)
		var end_point = Vector2(0, 0)
		var time_1 = Global.timeline_beats[beat]
		var time_2 = time_1 + 60.0 * Global.beats_per_bar / bpm * (duration_x / duration_y) 
		if current_time < time_1 - Global.note_speed_in_time or current_time > time_2:
			$Preview.visible = false
			for line in $Preview/NoteShape.get_children():
				line = hexagon_shape(start_point, start_point, line)
		else:
			if current_time < time_2 and current_time > time_2 - Global.note_speed_in_time * 0.7 : # tail position
				end_progress = (current_time - time_2 + Global.note_speed_in_time * 0.7) / (Global.note_speed_in_time * 0.7)
			elif time_2 - Global.note_speed_in_time * 0.7 >= current_time:
				end_progress = 0
			else:
				end_progress = 1
			end_point = Vector2(sin(angle), -cos(angle)) * (Global.preview_radius - Global.initial_note_distance) * end_progress
			
			for line in $Preview/NoteShape.get_children():
					line.scale = Vector2(1, 1)
					line.self_modulate.a = 1
			if current_time < time_1 and current_time > time_1 - Global.note_speed_in_time * 0.7: # head position changing
				start_progress = (current_time - time_1 + Global.note_speed_in_time * 0.7) / (Global.note_speed_in_time * 0.7)
				print(start_progress)
			elif time_1 - Global.note_speed_in_time * 0.7 > current_time and time_1 - Global.note_speed_in_time < current_time:
				var progress = (current_time - time_1 + Global.note_speed_in_time) / Global.note_speed_in_time * 0.3
				for line in $Preview/NoteShape.get_children():
					line.scale = Vector2(0.5 + 0.5 * progress,0.5 + 0.5 * progress)
					line.self_modulate.a = progress
					start_progress = 0
			elif current_time > time_1:
				start_progress = 1
			else:
				start_progress = 0
			start_point = Vector2(sin(angle), -cos(angle)) * (Global.preview_radius - Global.initial_note_distance) * start_progress
			for line in $Preview/NoteShape.get_children():
				hexagon_shape(start_point, end_point, line)
			$Preview.visible = true
			

	

func initialize() -> void:
	if note_property_touch: # touch hold logic
		pass
	else: # hold logic
		for node in $Preview.get_children():
			node.free()
		var new_node = Node2D.new()
		new_node.name = "NoteShape"
		var angle = (int(note_position) * 2 - 1) * TAU / 16
		new_node.position = Global.preview_center + Vector2(Global.initial_note_distance * sin(angle), -Global.initial_note_distance * cos(angle))
		$Preview.add_child(new_node)
		if note_property_ex:
			var highlight_hold = hexagon_shape(Vector2(0, 0), Vector2(0, 0))
			highlight_hold.color = Global.note_colors["note_highlight"]
			highlight_hold.width = 18
			$Preview/NoteShape.add_child(highlight_hold)
		var note_outline = hexagon_shape(Vector2(0, 0), Vector2(0, 0))
		note_outline.default_color = Color.WHITE
		note_outline.width = 11
		$Preview/NoteShape.add_child(note_outline)
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
		$Preview/NoteShape.add_child(note_hold)
		
func timeline_object_render() -> void: #TODO change visible range
	var time = Global.timeline_beats[beat]
	if time > Global.timeline_visible_time_range["Start"] and time < Global.timeline_visible_time_range["End"]:
		$TimelineIndicator.visible = true
		$TimelineIndicator.position = Vector2(Global.time_to_timeline_pos_x(time), 516)
	else:
		$TimelineIndicator.visible = false

func hexagon_shape(point_1: Vector2, point_2: Vector2, hexagon: Line2D = null) -> Line2D:
	var angle = ((int(note_position) * 2 - 1) * TAU / 16) + TAU / 4
	if !hexagon:
		var new_line = Line2D.new()
		new_line.closed = true
		new_line.add_point(point_1 + Vector2(-18, 0).rotated(angle - TAU / 6))
		new_line.add_point(point_1 + Vector2(-18, 0).rotated(angle))
		new_line.add_point(point_1 + Vector2(-18, 0).rotated(angle + TAU / 6))
		new_line.add_point(point_2 + Vector2(-18, 0).rotated(angle + 2 * TAU / 6))
		new_line.add_point(point_2 + Vector2(-18, 0).rotated(angle + 3 * TAU / 6))
		new_line.add_point(point_2 + Vector2(-18, 0).rotated(angle + 4 * TAU / 6))
		return new_line
	else:
		hexagon.set_point_position(0, point_1 + Vector2(-18, 0).rotated(angle - TAU / 6))
		hexagon.set_point_position(1, point_1 + Vector2(-18, 0).rotated(angle))
		hexagon.set_point_position(2, point_1 + Vector2(-18, 0).rotated(angle + TAU / 6))
		hexagon.set_point_position(3, point_2 + Vector2(18, 0).rotated(angle - TAU / 6))
		hexagon.set_point_position(4, point_2 + Vector2(18, 0).rotated(angle))
		hexagon.set_point_position(5, point_2 + Vector2(18, 0).rotated(angle + TAU / 6))
		return hexagon
