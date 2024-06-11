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
	
	var note_pathfollow = $Note/Path2D/PathFollow2D
	
	for node in note_pathfollow.get_children():
		node.scale = Vector2(scale_progress, scale_progress)
		node.self_modulate.a = scale_progress
		
	note_pathfollow.progress_ratio = path_progress

func slider_render(current_time: float) -> void:
	pass

func initialize(pos: String = note_position) -> void:
	if !note_property_touch: # tap note logic
		var note_pos = Global.note_pos_mod(int(pos))
		var angle = (note_pos * 2 - 1) * TAU / 16
		$Note.position = Global.preview_center + Global.initial_note_distance * Vector2(sin(angle), -cos(angle))
		$Sliders.position = $Note.position
		
		var note_color
		if note_property_break:
			note_color = Global.note_colors["note_break"]
		elif note_property_both:
			note_color = Global.note_colors["note_both"]
		else:
			note_color = Global.note_colors["note_base"]
		
		var note_path = $Note/Path2D
		var note_pathfollow = $Note/Path2D/PathFollow2D
		
		for node in note_pathfollow.get_children():
			node.queue_free()
		
		if sliders.size() == 0:
			if note_property_ex:
				var note_highlight = circle(Global.note_colors["note_highlight"], 18)
				note_pathfollow.add_child(note_highlight)
			var note_outline = circle(Color.WHITE, 11)
			note_pathfollow.add_child(note_outline)
			var note_circle = circle(note_color, 8)
			note_pathfollow.add_child(note_circle)
		else: # star tap
			if note_property_ex:
				var note_highlight = star(Global.note_colors["note_highlight"], 18)
				note_pathfollow.add_child(note_highlight)
			var note_outline = star(Color.WHITE, 11)
			note_pathfollow.add_child(note_outline)
			var note_star = star(note_color, 8)
			note_pathfollow.add_child(note_star)
			
		var new_curve = Curve2D.new()
		var start_point = Vector2(0, 0)
		new_curve.add_point(start_point)
		var end_point = (Global.preview_radius - Global.initial_note_distance) * Vector2(sin(angle), -cos(angle))
		new_curve.add_point(end_point)
		note_path.curve = new_curve
		
		for slider in sliders: # sliders
			pass
			
		# Timeline stuffs
		for node in $TimelineIndicator.get_children():
			node.free()
		var new_line = circle(note_color, 2, 4, 16)
		new_line.default_color = note_color
		new_line.position = Vector2(0, 15 * note_pos - 6)
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

func star(color: Color, width: float,  radius: float = 18): # star tap
	var newLine = Line2D.new()
	newLine.default_color = color
	newLine.width = width
	for i in range(5):
		newLine.add_point(Vector2(sin(i * TAU / 5), cos(i * TAU / 5)) * radius)
		newLine.add_point(Vector2(sin((i * 2 + 1) * TAU / 10), cos((i * 2 + 1) * TAU / 10)) * radius * sin(deg_to_rad(18) / sin(deg_to_rad(126))))
	return newLine
