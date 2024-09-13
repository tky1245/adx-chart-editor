class_name Touch extends Note

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
				effect_trigger.emit("touch_hit", note_position)
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
			#$Note/JudgeOutline.visible = true if current_time > judge_time + 0.15 else false
			$Note.visible = true
			scale_progress = 1
			path_progress = (current_time - move_time) / (judge_time - move_time)
		
		
		var size = 45 - path_progress * 18
		var line = $Note/SelectedHighlight
		line.clear_points()
		if note_property_star:
			for i in range(5):
				var vec = Vector2(cos(i * TAU/5), sin(i * TAU/5)) * size / cos(TAU/10)
				line.add_point(vec)
		else:
			for i in range(4):
				var vec = Vector2(cos(i * TAU/4+TAU/8), sin(i * TAU/4+TAU/8)) * size / cos(TAU/8)
				line.add_point(vec)
		if $Note.visible:
			for i in range(5):
				if path_progress < 0.9:
					$Note/JudgeOutline.visible = false
					var note_pathfollow = $Note.get_child(i).get_child(0).get_child(0)
					note_pathfollow.progress_ratio = path_progress / 0.9 
				else:
					$Note/JudgeOutline.visible = true
			set_node_images_transparency($Note, scale_progress)

func sfx_trigger(previous_time: float, current_time: float, offset: float = Global.sfx_offset):
	var delay_tick_time = (delay_ticks / bpm / 128 * Global.beats_per_bar)
	var judge_time: float = Global.timeline_beats[beat] + delay_tick_time
	
	if previous_time < judge_time - offset and current_time >= judge_time - offset:
		Sound.sfx_start.emit("answer", 0)
		Sound.sfx_start.emit("touch", 0)
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
		touch_star_draw()
	else:
		touch_draw()
	set_selected()

func touch_draw() -> void:
	# Colors
	var note_color_outer
	var note_color_inner
	var note_color_outline = Color.BLACK
	var _note_color_highlight_ex
	
	if note_property_mine:
		note_color_outer = Global.note_colors["touch_outer_mine"]
		note_color_inner = Global.note_colors["touch_inner_mine"]
		_note_color_highlight_ex = Global.note_colors["touch_highlight_ex_mine"]
	elif note_property_break:
		note_color_outer = Global.note_colors["touch_outer_break"]
		note_color_inner = Global.note_colors["touch_inner_break"]
		_note_color_highlight_ex = Global.note_colors["touch_highlight_ex_break"]
	elif note_property_both:
		note_color_outer = Global.note_colors["touch_outer_both"]
		note_color_inner = Global.note_colors["touch_inner_both"]
		_note_color_highlight_ex = Global.note_colors["touch_highlight_ex_both"]
	else:
		note_color_outer = Global.note_colors["touch_outer_base"]
		note_color_inner = Global.note_colors["touch_inner_base"]
		_note_color_highlight_ex = Global.note_colors["touch_highlight_ex_base"]
	
	# Center dot
	for node in $Note/CenterDot.get_children():
		node.queue_free()
	var note_center_outline = circle(Color.BLACK, 7, 2, 16)
	$Note/CenterDot.add_child(note_center_outline)
	var note_center_dot = circle(note_color_outer, 5, 2, 16)
	$Note/CenterDot.add_child(note_center_dot)
	
	# Judge outline
	var outline_size = 25
	var judge_outline = $Note/JudgeOutline/Line2D
	judge_outline.clear_points()
	for i in range(4):
		judge_outline.add_point(Vector2(outline_size, outline_size - 8).rotated(i * TAU / 4))
		judge_outline.add_point(Vector2(outline_size - 2, outline_size - 2).rotated(i * TAU / 4))
		judge_outline.add_point(Vector2(outline_size - 8, outline_size).rotated(i * TAU / 4))

	
	# 4 Segments and their pathing
	for i in range(4):
		var note_path = $Note.get_child(i).get_child(0)
		var note_pathfollow = note_path.get_child(0)
		for node in note_pathfollow.get_children():
			node.queue_free()
		
		var size = 22
		var width = 6
		var segment_outer = Polygon2D.new()
		segment_outer.polygon = touch_outer(size, width, 2)
		segment_outer.color = note_color_outer
		note_pathfollow.add_child(segment_outer)
		var segment_inner = Polygon2D.new()
		segment_inner.polygon = touch_inner(size, width, 2)
		segment_inner.color = note_color_inner
		note_pathfollow.add_child(segment_inner)
		var note_outline_in = Line2D.new()
		for point in triangle(size-width*(1+2*sin(TAU/8)), 2+width*2*sin(TAU/8)):
			note_outline_in.add_point(point)
		note_outline_in.default_color = Color.WHITE
		note_outline_in.closed = true
		note_outline_in.width = 1
		note_pathfollow.add_child(note_outline_in)
		var note_outline_out = Line2D.new()
		for point in touch(size, 2):
			note_outline_out.add_point(point)
		note_outline_out.default_color = Color.WHITE
		note_outline_out.closed = true
		note_outline_out.width = 1
		note_pathfollow.add_child(note_outline_out)
		var note_outline_out_2 = Line2D.new()
		for point in touch(size+4, 0.5):
			note_outline_out_2.add_point(point)
		note_outline_out_2.default_color = Color.BLACK
		note_outline_out_2.closed = true
		note_outline_out_2.width = 1
		note_pathfollow.add_child(note_outline_out_2)
		
		var offset = 12
		var new_curve = Curve2D.new()
		new_curve.add_point(Vector2(6 + offset, 0).rotated(TAU * i / 4))
		new_curve.add_point(Vector2(0, 0))
		note_path.curve = new_curve
	for node in $Note/Segment4/Path2D/PathFollow2D.get_children():
		node.queue_free()
	timeline_object_draw()

func touch_star_draw() -> void:
	# Colors
	var note_color_outer
	var note_color_inner
	var note_color_outline = Color.BLACK
	var _note_color_highlight_ex
	
	if note_property_mine:
		note_color_outer = Global.note_colors["star_outer_mine"]
		note_color_inner = Global.note_colors["star_inner_mine"]
		_note_color_highlight_ex = Global.note_colors["star_highlight_ex_mine"]
	if note_property_break:
		note_color_outer = Global.note_colors["star_outer_break"]
		note_color_inner = Global.note_colors["star_inner_break"]
		_note_color_highlight_ex = Global.note_colors["star_highlight_ex_break"]
	elif note_property_both:
		note_color_outer = Global.note_colors["star_outer_both"]
		note_color_inner = Global.note_colors["star_inner_both"]
		_note_color_highlight_ex = Global.note_colors["star_highlight_ex_both"]
	else:
		note_color_outer = Global.note_colors["star_outer_base"]
		note_color_inner = Global.note_colors["star_inner_base"]
		_note_color_highlight_ex = Global.note_colors["star_highlight_ex_base"]
	
	#TODO: redo touch star drawing
	# Center dot
	for node in $Note/CenterDot.get_children():
		node.queue_free()
	
	# 5 Segments and pathing
	for i in range(5):
		var note_path = $Note.get_child(i).get_child(0)
		var note_pathfollow = note_path.get_child(0)
		for node in note_pathfollow.get_children():
			node.queue_free()
		var note_polygon = Polygon2D.new()
		note_polygon.polygon = star_rhombus()
		note_polygon.color = note_color_outer
		note_polygon.rotation = PI
		note_pathfollow.add_child(note_polygon)
		var outline = Line2D.new()
		for point in note_polygon.polygon:
			outline.add_point(point)
		outline.default_color = note_color_inner
		outline.width = 2
		outline.rotation = PI
		note_pathfollow.add_child(outline)
		var new_curve = Curve2D.new()
		new_curve.add_point(Vector2(20, 0).rotated(TAU * i / 5))
		new_curve.add_point(Vector2(0, 0))
		note_path.curve = new_curve
	timeline_object_draw()

func timeline_object_draw() -> void:
	if !note_property_star:
		var note_color_timeline_indicator
		if note_property_mine:
			note_color_timeline_indicator = Global.note_colors["touch_indicator_mine"]
		if note_property_break:
			note_color_timeline_indicator = Global.note_colors["touch_indicator_break"]
		elif note_property_both:
			note_color_timeline_indicator = Global.note_colors["touch_indicator_both"]
		else:
			note_color_timeline_indicator = Global.note_colors["touch_indicator_base"]
		
		for node in $TimelineIndicator.get_children():
			node.free()
		var new_line = Line2D.new()
		new_line.default_color = note_color_timeline_indicator
		new_line.width = 2
		for i in range(4):
			new_line.add_point(Vector2(4, 4).rotated(i * TAU/4))
		new_line.closed = true
		$TimelineIndicator.position = Vector2(0, 15 * int(note_position) + 510)
		$TimelineIndicator.add_child(new_line)
		var indicator_highlight = Line2D.new()
		var poly = [Vector2(8, 8), Vector2(8, -8), Vector2(-8, -8), Vector2(-8, 8)]
		indicator_highlight.name = "IndicatorHighlight"
		indicator_highlight.points = poly
		indicator_highlight.closed = true
		indicator_highlight.default_color = Color.LIME
		indicator_highlight.width = 2
		$TimelineIndicator.add_child(indicator_highlight)
	else:
		var note_color_timeline_indicator
		if note_property_mine:
			note_color_timeline_indicator = Global.note_colors["star_indicator_mine"]
		elif note_property_break:
			note_color_timeline_indicator = Global.note_colors["star_indicator_break"]
		elif note_property_both:
			note_color_timeline_indicator = Global.note_colors["star_indicator_both"]
		else:
			note_color_timeline_indicator = Global.note_colors["star_indicator_base"]
		# TODO: new shape for this?
		for node in $TimelineIndicator.get_children():
			node.free()
		var new_line = Line2D.new()
		new_line.default_color = note_color_timeline_indicator
		new_line.width = 2
		new_line.add_point(Vector2(4, 4))
		new_line.add_point(Vector2(4, -4))
		new_line.add_point(Vector2(-4, -4))
		new_line.add_point(Vector2(-4, 4))
		new_line.closed = true
		$TimelineIndicator.position = Vector2(0, 15 * int(note_position) + 510)
		$TimelineIndicator.add_child(new_line)
		var indicator_highlight = Line2D.new()
		var poly = [Vector2(8, 8), Vector2(8, -8), Vector2(-8, -8), Vector2(-8, 8)]
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
	$Note.position = Global.preview_center + Global.touch_positions[note_position]
	$Sliders.position = $Note.position
	for slider in $Sliders.get_children():
		slider.queue_free()
	for slider_args in sliders: # make sliders
		if sliders.size() > 1:
			slider_args["slider_property_both"] = true
		create_slider(slider_args)

func set_selected(option: bool = selected):
	selected = option
	$Note/SelectedHighlight.visible = selected
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
		var note_selected_highlight = $Note/SelectedHighlight
		arr.append(note_selected_highlight.points * Transform2D(0.0, -note_selected_highlight.global_position))
	for slider in $Sliders.get_children():
		arr.append_array(slider.select_area())
	return arr

func set_node_images_transparency(node: Node2D, transparency: float) -> void:
	if node.get_children().size() == 0:
		node.self_modulate.a = transparency
	else:
		for child_node in node.get_children():
			set_node_images_transparency(child_node, transparency)

func circle(color: Color, width: float, radius: float = 18, frequency: int = 360) -> Line2D:
	var newLine = Line2D.new()
	newLine.default_color = color
	newLine.width = width
	for i in range(frequency + 1):
		var angle = i * TAU / frequency
		newLine.add_point(Vector2(radius * sin(angle), radius * cos(angle)))
	return newLine

func triangle(size: float, offset: float) -> PackedVector2Array:
	var polygon: PackedVector2Array = []
	polygon.append(Vector2(-offset, 0))
	polygon.append(Vector2(-offset-size, size))
	polygon.append(Vector2(-offset-size, -size))
	return polygon

func touch(size: float, offset: float) -> PackedVector2Array:
	var polygon: PackedVector2Array = []
	var dy: float = (size - 22)/4.0 * 5 / sqrt(3)
	var dx: float = (size - 22)/4.0 * sqrt(3)
	polygon.append(Vector2(-offset, 0))
	polygon.append(Vector2(-offset-size+3+dx, size-3-dy))
	polygon.append(Vector2(-offset-size+dx, size-8-dy))
	polygon.append(Vector2(-offset-size+dx, -size+8+dy))
	polygon.append(Vector2(-offset-size+3+dx, -size+3+dy))
	return polygon

func touch_outer(size: float, width: float, offset: float) -> PackedVector2Array:
	var polygon: PackedVector2Array = []
	polygon.append(Vector2(-offset-size+width, size-width*(1+2*sin(TAU/8))))
	polygon.append(Vector2(-offset-size+width*(1+sin(TAU/8)), size-width*(1+sin(TAU/8))))
	polygon.append(Vector2(-offset-size+4, size-4))
	polygon.append(Vector2(-offset-size, size-8))
	polygon.append(Vector2(-offset-size, -size+8))
	polygon.append(Vector2(-offset-size+4, -size+4))
	polygon.append(Vector2(-offset-size+width*(1+sin(TAU/8)), -size+width*(1+sin(TAU/8))))
	polygon.append(Vector2(-offset-size+width, -size+width*(1+2*sin(TAU/8))))
	return polygon

func touch_inner(size: float, width: float, offset: float) -> PackedVector2Array:
	var polygon: PackedVector2Array = []
	polygon.append(Vector2(-offset, 0))
	polygon.append(Vector2(-offset-size+width*(1+sin(TAU/8)), size-width*(1+sin(TAU/8))))
	polygon.append(Vector2(-offset-size+width, size-width*(1+2*sin(TAU/8))))
	polygon.append(Vector2(-offset-2*width*sin(TAU/8), 0))
	polygon.append(Vector2(-offset-size+width, -size+width*(1+2*sin(TAU/8))))
	polygon.append(Vector2(-offset-size+width*(1+sin(TAU/8)), -size+width*(1+sin(TAU/8))))
	return polygon

func star_rhombus(inner_radius: float = 16, outer_radius: float = 26) -> PackedVector2Array: # for touch stars
	var new_polygon: PackedVector2Array = []
	new_polygon.append(Vector2(outer_radius - outer_radius * sin(TAU/10)*cos(TAU/20)/sin(TAU*7/20), -outer_radius*sin(TAU/10)*sin(TAU/20)/sin(TAU*7/20)))
	new_polygon.append(Vector2(outer_radius, 0))
	new_polygon.append(Vector2(outer_radius - outer_radius * sin(TAU/10)*cos(TAU/20)/sin(TAU*7/20), outer_radius*sin(TAU/10)*sin(TAU/20)/sin(TAU*7/20)))
	new_polygon.append(Vector2(inner_radius - inner_radius * sin(TAU/10)*cos(TAU/20)/sin(TAU*7/20), inner_radius*sin(TAU/10)*sin(TAU/20)/sin(TAU*7/20)))
	new_polygon.append(Vector2(inner_radius, 0))
	new_polygon.append(Vector2(inner_radius - inner_radius * sin(TAU/10)*cos(TAU/20)/sin(TAU*7/20), -inner_radius*sin(TAU/10)*sin(TAU/20)/sin(TAU*7/20)))
	return new_polygon
