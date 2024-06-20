extends Node2D
var beat: int
var bpm: float
var note_property_break: bool
var note_property_ex: bool
var note_property_touch: bool
var note_property_firework: bool
var note_property_both: bool
var note_property_star: bool
var note_position: String
var sliders: Array = []

var selected: bool

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
	
	set_node_images_transparency($Note, scale_progress)
	for i in range(5):
		var note_pathfollow = $Note.get_child(i).get_child(0).get_child(0)
		note_pathfollow.progress_ratio = path_progress
	
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

	
func slider_render(current_time: float) -> void:
	for slider in $Sliders.get_children():
		slider.slider_render(current_time)

func initialize() -> void:
	set_note_position()
	if note_property_star:
		touch_star_draw()
	else:
		touch_draw()
	
	# Selected highlight
	$Note/SelectedHighlight.default_color = Color.LIME


func touch_draw() -> void:
	# Colors
	var note_color_timeline_indicator
	var note_color_outer
	var note_color_inner
	var note_color_outline = Color.BLACK
	var _note_color_highlight_ex
	
	if note_property_break:
		note_color_timeline_indicator = Global.note_colors["touch_indicator_break"]
		note_color_outer = Global.note_colors["touch_outer_break"]
		note_color_inner = Global.note_colors["touch_inner_break"]
		_note_color_highlight_ex = Global.note_colors["touch_highlight_ex_break"]
	elif note_property_both:
		note_color_timeline_indicator = Global.note_colors["touch_indicator_both"]
		note_color_outer = Global.note_colors["touch_outer_both"]
		note_color_inner = Global.note_colors["touch_inner_both"]
		_note_color_highlight_ex = Global.note_colors["touch_highlight_ex_both"]
	else:
		note_color_timeline_indicator = Global.note_colors["touch_indicator_base"]
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
	
	
	
	# Timeline stuff
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
	new_line.position = Vector2(0, 15 * int(note_position) - 6)
	$TimelineIndicator.add_child(new_line)

func touch_star_draw() -> void:
	# Colors
	var note_color_timeline_indicator
	var note_color_outer
	var note_color_inner
	var note_color_outline = Color.BLACK
	var _note_color_highlight_ex
	
	if note_property_break:
		note_color_timeline_indicator = Global.note_colors["star_indicator_break"]
		note_color_outer = Global.note_colors["star_outer_break"]
		note_color_inner = Global.note_colors["star_inner_break"]
		_note_color_highlight_ex = Global.note_colors["star_highlight_ex_break"]
	elif note_property_both:
		note_color_timeline_indicator = Global.note_colors["star_indicator_both"]
		note_color_outer = Global.note_colors["star_outer_both"]
		note_color_inner = Global.note_colors["star_inner_both"]
		_note_color_highlight_ex = Global.note_colors["star_highlight_ex_both"]
	else:
		note_color_timeline_indicator = Global.note_colors["star_indicator_base"]
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
	
	# Timeline stuff
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
	new_line.position = Vector2(0, 15 * int(note_position) - 6)
	$TimelineIndicator.add_child(new_line)

func set_note_position(pos: String = note_position) -> void:
	note_position = pos
	$Note.position = Global.preview_center + Global.touch_positions[note_position]
	$Sliders.position = $Note.position

func timeline_object_render() -> void:
	var time = Global.timeline_beats[beat]
	if time > Global.timeline_visible_time_range["Start"] and time < Global.timeline_visible_time_range["End"]:
		$TimelineIndicator.visible = true
		$TimelineIndicator.position = Vector2(Global.time_to_timeline_pos_x(time), 516)
	else:
		$TimelineIndicator.visible = false
	for slider in $Sliders.get_children():
		slider.timeline_object_render()

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

func create_slider(slider_args: Dictionary):
	var slider = preload("res://note detail stuffs/slider.tscn")
	var new_slider = slider.instantiate()
	new_slider.beat = beat
	new_slider.bpm = bpm
	new_slider.slider_head_position = note_position
	for key in slider_args:
		new_slider.set(key, slider_args[key])
	new_slider.initialize($Sliders.position - Global.preview_center)
	$Sliders.add_child(new_slider)

func delete_slider(slider_index: int):
	$Sliders.get_child(slider_index).queue_free()
	sliders.pop_at(slider_index)

func set_node_images_transparency(node: Node2D, transparency: float) -> void:
	if node.get_children().size() == 0:
		node.self_modulate.a = transparency
	else:
		for child_node in node.get_children():
			set_node_images_transparency(child_node, transparency)

func set_selected(option: bool = selected):
	selected = option
	$Note/SelectedHighlight.visible = selected
	for slider_node in $Sliders.get_children():
		slider_node.set_selected(selected)
