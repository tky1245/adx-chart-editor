extends Node2D
var beat: int
var bpm: float
var note_property_break: bool
var note_property_ex: bool
var note_property_touch: bool
var note_property_firework: bool
var note_property_both: bool
var note_property_slider: bool
var note_position: String
var sliders: Array = []

func preview_render(current_time: float) -> void:
	note_render(current_time)
	slider_render(current_time)

func note_render(current_time: float) -> void:
	var intro_time: float = Global.timeline_beats[beat] - Global.note_speed_in_time
	var move_time: float = Global.timeline_beats[beat] - Global.note_speed_in_time * 0.7
	var judge_time: float = Global.timeline_beats[beat]
	var scale_progress: float
	var path_progress: float
	
	if current_time < intro_time:
		$Note.visible = false
		scale_progress = 0
		path_progress = 0
	elif current_time < move_time:
		$Note.visible = true
		scale_progress = (current_time - intro_time) / (move_time - intro_time)
		path_progress = 0
	elif current_time < judge_time:
		$Note.visible = true
		scale_progress = 1
		path_progress = (current_time - move_time) / (judge_time - move_time)
	else:
		$Note.visible = false
		scale_progress = 1
		path_progress = 1
	
	for i in range(5):
		var note_pathfollow = $Note.get_child(i).get_child(0).get_child(0)
		
		for node in note_pathfollow.get_children():
			#node.scale = Vector2(scale_progress, scale_progress)
			node.self_modulate.a = scale_progress
		
		note_pathfollow.progress_ratio = path_progress

func slider_render(current_time: float) -> void:
	pass

func initialize() -> void:
	if note_property_touch: # touch note logic
		var note_pos = Global.preview_center + Global.touch_positions[note_position]
		$Note.position = note_pos
		$Sliders.position = note_pos
		var note_color
		if note_property_break: # um break touches
			note_color = Global.note_colors["note_break"]
		elif note_property_both:
			note_color = Global.note_colors["note_both"]
		elif note_property_slider and sliders.size() > 0:
			note_color = Global.note_colors["star_outer"]
		else:
			note_color = Global.note_colors["touch_base"]
		
		for node in $Note/CenterDot.get_children():
			node.queue_free()
		
		var note_center_highlight = circle(Color.WHITE, 10, 2, 16)
		$Note/CenterDot.add_child(note_center_highlight)
		var note_center_dot = circle(note_color, 6, 2, 16)
		$Note/CenterDot.add_child(note_center_dot)
		
		if sliders.size() == 0: # normal touch
			for i in range(4):
				var note_path = $Note.get_child(i).get_child(0)
				var note_pathfollow = note_path.get_child(0)
				for node in note_pathfollow.get_children():
					node.queue_free()
				var note_outline = triangle(Color.WHITE, 10)
				note_pathfollow.add_child(note_outline)
				var note_triangle_part = triangle(note_color, 6)
				note_pathfollow.add_child(note_triangle_part)
				var offset = 12
				var new_curve = Curve2D.new()
				new_curve.add_point(Vector2(9 + offset, 0).rotated(TAU * i / 4))
				new_curve.add_point(Vector2(9, 0).rotated(TAU * i / 4))
				note_path.curve = new_curve
			for node in $Note/Segment4/Path2D/PathFollow2D.get_children():
				node.queue_free()
		else: # touch slider's note
			pass
		
		for slider in sliders: # sliders
			pass
		
		# Timeline stuff
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
		new_line.position = Vector2(0, 15 * int(note_position) - 6)
		$TimelineIndicator.add_child(new_line)

func timeline_object_render() -> void:
	if !note_property_slider:
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

func star_rhombus(color: Color, width: float,  radius: float = 18): # for touch stars
	pass
