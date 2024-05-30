extends Node2D
var beat: int
var bpm: float
var note_property_break: bool
var note_property_ex: bool
var note_property_touch: bool
var note_property_firework: bool
var note_property_both: bool
var note_position: String
	
func preview_render(current_time: float) -> void:
	if current_time < Global.timeline_beats[beat] - Global.note_speed_in_time or current_time > Global.timeline_beats[beat]:
		$Preview.visible = false
		for note_path in $Preview.get_children():
			note_path.get_child(0).progress_ratio = 0
	else:
		
		var progress = (current_time - Global.timeline_beats[beat] + Global.note_speed_in_time) / Global.note_speed_in_time
		# 0.3 growing 0.7 moving
		if progress <= 0.3:
			for note_path in $Preview.get_children():
				note_path.get_child(0).get_child(0).scale = Vector2(progress/0.3,progress/0.3)
				note_path.get_child(0).get_child(0).self_modulate.a = progress/0.3

		else:
			for note_path in $Preview.get_children():
				note_path.get_child(0).get_child(0).scale = Vector2(1, 1)
				note_path.get_child(0).get_child(0).self_modulate.a = 1
				note_path.get_child(0).progress_ratio = (progress - 0.3) / 0.7
		$Preview.visible = true

func initialize(pos: String = note_position) -> void:
	if note_property_touch: # touch note logic
		var note_pos = Global.touch_positions[pos]
		var note_color
		for node in $Preview.get_children():
				node.free()
		for i in range(5):
			var new_path = Path2D.new()
			new_path.name = "NotePath" + str(i)
			$Preview.add_child(new_path)
			var note_path = $Preview.get_child(i)
			var new_path_follow = PathFollow2D.new()
			new_path_follow.name = "NotePathFollow"
			note_path.add_child(new_path_follow)
			var new_node = Node2D.new()
			new_node.name = "NoteShape"
			note_path.get_child(0).add_child(new_node)
			var note_shape = note_path.get_child(0).get_child(0)
			if note_property_break: # um break touches
				note_color = Global.note_colors["note_break"]
			elif note_property_both:
				note_color = Global.note_colors["note_both"]
			else:
				note_color = Global.note_colors["touch_base"]
			if i != 4:
				var note_outline = triangle(Color.WHITE, 10)
				note_shape.add_child(note_outline)
				var note_triangle_part = triangle(note_color, 6)
				note_shape.add_child(note_triangle_part)
				var offset = 12
				var new_curve = Curve2D.new()
				new_curve.add_point(note_pos + Vector2(9 + offset, 0).rotated(TAU * i / 4))
				new_curve.add_point(note_pos + Vector2(9, 0).rotated(TAU * i / 4))
				note_path.curve = new_curve
			else: # awkward center dot
				var note_center_highlight = circle(Color.WHITE, 10, 2, 16)
				note_shape.add_child(note_center_highlight)
				var note_center_dot = circle(note_color, 6, 2, 16)
				note_shape.add_child(note_center_dot)
				note_shape.position = note_pos
				var new_curve = Curve2D.new()
				new_curve.add_point(note_pos + Vector2(0, 0))
				new_curve.add_point(note_pos + Vector2(0, 0))
				note_path.curve = new_curve
		for node in $TimelineIndicator.get_children():
			node.free()
		var new_line = Line2D.new()
		new_line.default_color = note_color
		new_line.width = 2
		new_line.add_point(Vector2(4, 4))
		new_line.add_point(Vector2(4, -4))
		new_line.add_point(Vector2(-4, -4))
		new_line.add_point(Vector2(-4, 4))
		new_line.closed = true
		new_line.position = Vector2(0, 15 * int(pos) - 6)
		$TimelineIndicator.add_child(new_line)
		
	else: # tap note logic
		for node in $Preview.get_children():
			node.free()
		var new_path = Path2D.new()
		new_path.name = "NotePath"
		$Preview.add_child(new_path)
		var new_path_follow = PathFollow2D.new()
		new_path_follow.name = "NotePathFollow"
		$Preview/NotePath.add_child(new_path_follow)
		var new_node = Node2D.new()
		new_node.name = "NoteShape"
		$Preview/NotePath/NotePathFollow.add_child(new_node)
		if note_property_ex:
			var highlight_circle = circle(Global.note_colors["note_highlight"], 18)
			$Preview/NotePath/NotePathFollow/NoteShape.add_child(highlight_circle)
		var note_outline = circle(Color.WHITE, 11)
		$Preview/NotePath/NotePathFollow/NoteShape.add_child(note_outline)
		var note_color
		if note_property_break:
			note_color = Global.note_colors["note_break"]
		elif note_property_both:
			note_color = Global.note_colors["note_both"]
		else:
			note_color = Global.note_colors["note_base"]
		var note_circle = circle(note_color, 8)
		$Preview/NotePath/NotePathFollow/NoteShape.add_child(note_circle)
		
		var note_pos = Global.note_pos_mod(int(pos))
		var angle = (note_pos * 2 - 1) * TAU / 16
		var new_curve = Curve2D.new()
		var start_point = Global.preview_center + Vector2(Global.initial_note_distance * sin(angle), -Global.initial_note_distance * cos(angle))
		new_curve.add_point(start_point)
		var end_point = Global.preview_center + Vector2(Global.preview_radius * sin(angle), -Global.preview_radius * cos(angle))
		new_curve.add_point(end_point)
		$Preview/NotePath.curve = new_curve
		
		for node in $TimelineIndicator.get_children():
			node.free()
		var new_line = circle(note_color, 2, 4, 16)
		new_line.default_color = note_color
		new_line.position = Vector2(0, 15 * note_pos - 6)
		$TimelineIndicator.add_child(new_line)

func timeline_object_render() -> void:
	var time = Global.timeline_beats[beat]
	if time > Global.timeline_visible_time_range["Start"] and time < Global.timeline_visible_time_range["End"]:
		$TimelineIndicator.visible = true
		$TimelineIndicator.position = Vector2(Global.time_to_timeline_pos_x(time), 516)
	else:
		$TimelineIndicator.visible = false

func circle(color: Color, width: float, radius: float = 18, frequency: int = 360) -> Line2D:
	var newLine = Line2D.new()
	newLine.default_color = color
	newLine.width = width
	for i in range(frequency + 1):
		var angle = i * TAU / frequency
		newLine.add_point(Vector2(radius * sin(angle), radius * cos(angle)))
	return newLine

func triangle(color: Color, width: float) -> Line2D:
	var newLine = Line2D.new()
	newLine.default_color = color
	newLine.width = width
	newLine.closed = true
	newLine.add_point(Vector2(-2, 0))
	newLine.add_point(Vector2(-16, 14))
	newLine.add_point(Vector2(-16, -14))
	return newLine
	
