class_name Tap extends Note

func note_render(current_time: float = Global.current_time) -> void:
	var delay_tick_time = (delay_ticks / bpm / 128 * Global.beats_per_bar)
	var intro_time: float = Global.timeline_beats[beat] + delay_tick_time - Global.note_speed_in_time
	var move_time: float = Global.timeline_beats[beat] + delay_tick_time - Global.note_speed_in_time * 0.7
	var judge_time: float = Global.timeline_beats[beat] + delay_tick_time
	var scale_progress: float
	var path_progress: float
	
	if slider_tapless and sliders.size() > 0:
		$Note.visible = false
	else:
		if current_time < intro_time:
			$Note.visible = false
			scale_progress = 0
			path_progress = 0
		elif current_time > judge_time:
			if $Note.visible:
				if !note_property_break:
					effect_trigger.emit("tap_hit", note_position)
				else:
					effect_trigger.emit("break_hit", note_position)
				if note_property_firework:
					effect_trigger.emit("firework", note_position)
			$Note.visible = false
			scale_progress = 1
			path_progress = 1
		elif current_time <= move_time:
			$Note.visible = true
			scale_progress = (current_time - intro_time) / (move_time - intro_time)
			path_progress = 0
		elif current_time <= judge_time:
			$Note.visible = true
			scale_progress = 1
			path_progress = (current_time - move_time) / (judge_time - move_time)

		var note_pathfollow = $Note/Path2D/PathFollow2D
		note_pathfollow.progress_ratio = path_progress
		if $Note.visible:
			for node in note_pathfollow.get_children():
				node.scale = Vector2(scale_progress, scale_progress)
				node.self_modulate.a = scale_progress
			
			if note_property_star and note_star_spinning:
				for node in note_pathfollow.get_children():
					node.rotation = current_time * TAU * 4 #TODO probably need to set a correct speed
			else:
				for node in note_pathfollow.get_children():
					node.rotation = 0

func sfx_trigger(previous_time: float, current_time: float, offset: float = Global.sfx_offset):
	var delay_tick_time = (delay_ticks / bpm / 128 * Global.beats_per_bar)
	var judge_time: float = Global.timeline_beats[beat] + delay_tick_time
	
	if previous_time < judge_time - offset and current_time >= judge_time - offset:
		Sound.sfx_start.emit("answer", 0)
		Sound.sfx_start.emit("judge", 0)
		if note_property_break:
			Sound.sfx_start.emit("break", 0)
			Sound.sfx_start.emit("judge_break", 0)
		if note_property_ex:
			Sound.sfx_start.emit("judge_ex", 0)
		if note_property_firework:
			Sound.sfx_start.emit("hanabi", 0)
	for slider in $Sliders.get_children():
		slider.sfx_trigger(previous_time, current_time)

func note_draw() -> void:
	if note_property_star:
		star_draw()
	else:
		tap_draw()
	set_selected()
	
func tap_draw() -> void:
	# Colors
	var note_color_outer
	var note_color_inner
	var note_color_highlight_ex
	
	if note_property_mine:
		note_color_outer = Global.note_colors["tap_outer_mine"]
		note_color_inner = Global.note_colors["tap_inner_mine"]
		note_color_highlight_ex = Global.note_colors["tap_highlight_ex_mine"]
	elif note_property_break:
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
	
	# Adding note shape
	var note_path = $Note/Path2D
	var note_pathfollow = $Note/Path2D/PathFollow2D
	for node in note_pathfollow.get_children():
		if node.name != "SelectedHighlight":
			node.queue_free()
	if note_property_ex:
		var note_highlight_ex = circle(note_color_highlight_ex, 17)
		note_pathfollow.add_child(note_highlight_ex)
	var note_outline = circle(Color.WHITE, 11) # TODO: redo tap drawing
	note_pathfollow.add_child(note_outline)
	var note_circle = circle(note_color_inner, 8)
	note_pathfollow.add_child(note_circle)
	var selected_highlight = $Note/Path2D/PathFollow2D/SelectedHighlight
	selected_highlight.points = circle(Color.LIME, 3, 30).points
	selected_highlight.default_color = Color.LIME
	timeline_object_draw()
	
func star_draw() -> void:
	# Colors
	var note_color_outer
	var note_color_inner
	var note_color_highlight_ex
	if note_property_mine:
		note_color_outer = Global.note_colors["star_outer_mine"]
		note_color_inner = Global.note_colors["star_inner_mine"]
		note_color_highlight_ex = Global.note_colors["star_highlight_ex_mine"]
	elif note_property_break:
		note_color_outer = Global.note_colors["star_outer_break"]
		note_color_inner = Global.note_colors["star_inner_break"]
		note_color_highlight_ex = Global.note_colors["star_highlight_ex_break"]
	elif note_property_both:
		note_color_outer = Global.note_colors["star_outer_both"]
		note_color_inner = Global.note_colors["star_inner_both"]
		note_color_highlight_ex = Global.note_colors["star_highlight_ex_both"]
	else:
		note_color_outer = Global.note_colors["star_outer_base"]
		note_color_inner = Global.note_colors["star_inner_base"]
		note_color_highlight_ex = Global.note_colors["star_highlight_ex_base"]
	
	var note_path = $Note/Path2D
	var note_pathfollow = $Note/Path2D/PathFollow2D
	for node in note_pathfollow.get_children():
		if node.name != "SelectedHighlight":
			node.queue_free()
	# Star tap
	if note_property_ex:
		var note_highlight = star(note_color_highlight_ex, 5, 27)
		note_pathfollow.add_child(note_highlight)
	var note_star_inner = star(note_color_inner, 4, 15)
	note_pathfollow.add_child(note_star_inner)
	var note_star_outer = star(note_color_outer, 2, 19.5)
	note_pathfollow.add_child(note_star_outer)
	var note_outline_in = star(Color.WHITE, 1, 10)
	note_pathfollow.add_child(note_outline_in)
	var note_outline_out = star(Color.WHITE, 1.2, 22)
	note_pathfollow.add_child(note_outline_out)
	var note_outline_out_2 = star(Color.BLACK, 1, 24)
	note_pathfollow.add_child(note_outline_out_2)
	var selected_highlight = $Note/Path2D/PathFollow2D/SelectedHighlight
	selected_highlight.points = star(Color.LIME, 3, 35).points
	selected_highlight.default_color = Color.LIME
	
	timeline_object_draw()

func timeline_object_draw() -> void:
	if !note_property_star:
		var note_color_timeline_indicator
		if note_property_mine:
			note_color_timeline_indicator = Global.note_colors["tap_indicator_mine"]
		elif note_property_break:
			note_color_timeline_indicator = Global.note_colors["tap_indicator_break"]
		elif note_property_both:
			note_color_timeline_indicator = Global.note_colors["tap_indicator_both"]
		else:
			note_color_timeline_indicator = Global.note_colors["tap_indicator_base"]
		
		$TimelineIndicator.position = Vector2(0, 15 * int(note_position) + 510)
		for node in $TimelineIndicator.get_children():
			node.free()
		var new_line = circle(note_color_timeline_indicator, 2, 4, 16)
		$TimelineIndicator.add_child(new_line)
		var highlight_line = circle(Color.LIME, 2, 8, 16)
		highlight_line.name = "IndicatorHighlight"
		$TimelineIndicator.add_child(highlight_line)
	else:
		var note_color_timeline_indicator
		if note_property_mine:
			note_color_timeline_indicator = Global.note_colors["tap_indicator_mine"]
		elif note_property_break:
			note_color_timeline_indicator = Global.note_colors["star_indicator_break"]
		elif note_property_both:
			note_color_timeline_indicator = Global.note_colors["star_indicator_both"]
		else:
			note_color_timeline_indicator = Global.note_colors["star_indicator_base"]
		
		$TimelineIndicator.position = Vector2(0, 15 * int(note_position) + 510)
		for node in $TimelineIndicator.get_children():
			node.free()
		var new_line = star(note_color_timeline_indicator, 2, 6)
		$TimelineIndicator.add_child(new_line)
		var highlight_line = star(Color.LIME, 2, 12)
		highlight_line.name = "IndicatorHighlight"
		$TimelineIndicator.add_child(highlight_line)
		
	for slider in $Sliders.get_children():
		slider.timeline_object_draw()

func set_note_position(pos: String = note_position) -> void:
	note_position = pos
	var angle = (Global.note_pos_mod(int(pos)) * 2 - 1) * TAU / 16
	$Note.position = Global.preview_center + Global.initial_note_distance * Vector2(sin(angle), -cos(angle))
	$Sliders.position = $Note.position
	$TimelineIndicator.position = Vector2(0, 15 * int(note_position) + 510)
	# Setting note path
	var new_curve = Curve2D.new()
	var start_point = Vector2(0, 0)
	new_curve.add_point(start_point)
	var end_point = (Global.preview_radius - Global.initial_note_distance) * Vector2(sin(angle), -cos(angle))
	new_curve.add_point(end_point)
	$Note/Path2D.curve = new_curve
	for slider in $Sliders.get_children():
		slider.queue_free()
	for slider_args in sliders: # make sliders
		if sliders.size() > 1:
			slider_args["slider_property_both"] = true
		create_slider(slider_args)

func set_selected(option: bool = selected):
	selected = option
	$Note/Path2D/PathFollow2D/SelectedHighlight.visible = selected
	$TimelineIndicator/IndicatorHighlight.visible = selected
	for slider_node in $Sliders.get_children():
		slider_node.set_selected(selected)
	preview_render()

func select_area() -> Array:
	var arr: Array = []
	if $TimelineIndicator.visible:
		var indicator_highlight = $TimelineIndicator/IndicatorHighlight
		arr.append(indicator_highlight.points * Transform2D(0.0, -indicator_highlight.global_position))
	if $Note.visible:
		var note_selected_highlight = $Note/Path2D/PathFollow2D.get_child($Note/Path2D/PathFollow2D.get_child_count() - 1)
		arr.append(note_selected_highlight.points * Transform2D(-note_selected_highlight.rotation, Vector2(0, 0)) * Transform2D(0.0, -note_selected_highlight.global_position))
	for slider in $Sliders.get_children():
		arr.append_array(slider.select_area())
	return arr

func circle(color: Color, width: float, radius: float = 18, frequency: int = 360) -> Line2D:
	var newLine = Line2D.new()
	newLine.default_color = color
	newLine.width = width
	for i in range(frequency + 1):
		var angle = i * TAU / frequency
		newLine.add_point(Vector2(radius * sin(angle), radius * cos(angle)))
	return newLine

func star(color: Color, width: float,  radius: float = 18) -> Line2D: # star tap
	var newLine = Line2D.new()
	newLine.default_color = color
	newLine.width = width
	newLine.closed = true
	newLine.sharp_limit = 999999999
	newLine.joint_mode = Line2D.LINE_JOINT_SHARP
	for i in range(5):
		newLine.add_point(Vector2(cos(i * TAU / 5), sin(i * TAU / 5)) * radius)
		newLine.add_point(Vector2(cos((i * 2 + 1) * TAU / 10), sin((i * 2 + 1) * TAU / 10)) * radius * 1.3 * sin(deg_to_rad(18) / sin(deg_to_rad(126))))
	return newLine
