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
var sliders: Array = [] # Consists of dicts

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
	
	var note_pathfollow = $Note/Path2D/PathFollow2D
	
	for node in note_pathfollow.get_children():
		node.scale = Vector2(scale_progress, scale_progress)
		node.self_modulate.a = scale_progress
		
	note_pathfollow.progress_ratio = path_progress
	
	#TODO: spin the note
	if note_property_star:
		for node in note_pathfollow.get_children():
			node.rotation = current_time * TAU * 10

func slider_render(current_time: float) -> void:
	for slider in $Sliders.get_children():
		slider.slider_render(current_time)

func initialize() -> void:
	set_note_position()
	if note_property_star:
		star_draw()
	else:
		tap_draw()
	
	for node in $Sliders.get_children():
		node.queue_free()
	for slider_args in sliders: # make sliders
		if sliders.size() > 1:
			slider_args["slider_property_both"] = true
		create_slider(slider_args)
	set_selected()

func tap_draw() -> void:
	# Colors
	var note_color_timeline_indicator
	var note_color_outer
	var note_color_inner
	var note_color_highlight_ex

	if note_property_break:
		note_color_timeline_indicator = Global.note_colors["tap_indicator_break"]
		note_color_outer = Global.note_colors["tap_outer_break"]
		note_color_inner = Global.note_colors["tap_inner_break"]
		note_color_highlight_ex = Global.note_colors["tap_highlight_ex_break"]
	elif note_property_both:
		note_color_timeline_indicator = Global.note_colors["tap_indicator_both"]
		note_color_outer = Global.note_colors["tap_outer_both"]
		note_color_inner = Global.note_colors["tap_inner_both"]
		note_color_highlight_ex = Global.note_colors["tap_highlight_ex_both"]
	else:
		note_color_timeline_indicator = Global.note_colors["tap_indicator_base"]
		note_color_outer = Global.note_colors["tap_outer_base"]
		note_color_inner = Global.note_colors["tap_inner_base"]
		note_color_highlight_ex = Global.note_colors["tap_highlight_ex_base"]
	
	# Adding note shape
	var note_path = $Note/Path2D
	var note_pathfollow = $Note/Path2D/PathFollow2D
	for node in note_pathfollow.get_children():
		node.queue_free()
	if note_property_ex:
		var note_highlight_ex = circle(note_color_highlight_ex, 17)
		note_pathfollow.add_child(note_highlight_ex)
	var note_outline = circle(Color.WHITE, 11) # TODO: redo tap drawing
	note_pathfollow.add_child(note_outline)
	var note_circle = circle(note_color_inner, 8)
	note_pathfollow.add_child(note_circle)
	var selected_highlight = circle(Color.LIME, 3, 30)
	selected_highlight.name = "SelectedHighlight"
	note_pathfollow.add_child(selected_highlight)
	
	
	# Timeline stuffs
	for node in $TimelineIndicator.get_children():
		node.free()
	var new_line = circle(note_color_timeline_indicator, 2, 4, 16)
	new_line.position = Vector2(0, 15 * int(note_position) - 6)
	$TimelineIndicator.add_child(new_line)
	
func star_draw() -> void:
	# Colors
	var note_color_timeline_indicator
	var note_color_outer
	var note_color_inner
	var note_color_highlight_ex
	if note_property_break:
		note_color_timeline_indicator = Global.note_colors["star_indicator_break"]
		note_color_outer = Global.note_colors["star_outer_break"]
		note_color_inner = Global.note_colors["star_inner_break"]
		note_color_highlight_ex = Global.note_colors["star_highlight_ex_break"]
	elif note_property_both:
		note_color_timeline_indicator = Global.note_colors["star_indicator_both"]
		note_color_outer = Global.note_colors["star_outer_both"]
		note_color_inner = Global.note_colors["star_inner_both"]
		note_color_highlight_ex = Global.note_colors["star_highlight_ex_both"]
	else:
		note_color_timeline_indicator = Global.note_colors["star_indicator_base"]
		note_color_outer = Global.note_colors["star_outer_base"]
		note_color_inner = Global.note_colors["star_inner_base"]
		note_color_highlight_ex = Global.note_colors["star_highlight_ex_base"]
	
	var note_path = $Note/Path2D
	var note_pathfollow = $Note/Path2D/PathFollow2D
	for node in note_pathfollow.get_children():
		node.queue_free()
	# Star tap
	if note_property_ex:
		var note_highlight = star(note_color_highlight_ex, 5, 26)
		note_pathfollow.add_child(note_highlight)
	var note_star_inner = star(note_color_inner, 4, 15)
	note_pathfollow.add_child(note_star_inner)
	var note_star_outer = star(note_color_outer, 1, 19)
	note_pathfollow.add_child(note_star_outer)
	var note_outline_in = star(Color.WHITE, 1, 10)
	note_pathfollow.add_child(note_outline_in)
	var note_outline_out = star(Color.WHITE, 1, 22)
	note_pathfollow.add_child(note_outline_out)
	var note_outline_out_2 = star(Color.BLACK, 1, 24)
	note_pathfollow.add_child(note_outline_out_2)
	var selected_highlight = star(Color.LIME, 3, 35)
	selected_highlight.name = "SelectedHighlight"
	note_pathfollow.add_child(selected_highlight)
	
	# Timeline stuffs
	for node in $TimelineIndicator.get_children():
		node.free()
	var new_line = star(note_color_timeline_indicator, 2, 6)
	new_line.position = Vector2(0, 15 * int(note_position) - 6)
	$TimelineIndicator.add_child(new_line)

func set_note_position(pos: String = note_position) -> void:
	note_position = pos
	var angle = (Global.note_pos_mod(int(pos)) * 2 - 1) * TAU / 16
	$Note.position = Global.preview_center + Global.initial_note_distance * Vector2(sin(angle), -cos(angle))
	$Sliders.position = $Note.position
	
	# Setting note path
	var new_curve = Curve2D.new()
	var start_point = Vector2(0, 0)
	new_curve.add_point(start_point)
	var end_point = (Global.preview_radius - Global.initial_note_distance) * Vector2(sin(angle), -cos(angle))
	new_curve.add_point(end_point)
	$Note/Path2D.curve = new_curve

func create_slider(slider_args: Dictionary) -> void:
	var slider = preload("res://note detail stuffs/slider.tscn")
	var new_slider = slider.instantiate()
	new_slider.beat = beat
	new_slider.bpm = bpm
	new_slider.slider_head_position = note_position
	for key in slider_args:
		new_slider.set(key, slider_args[key])
	new_slider.initialize($Note.position - Global.preview_center)
	$Sliders.add_child(new_slider)

func delete_slider(slider_index: int) -> void:
	$Sliders.get_child(slider_index).queue_free()
	sliders.pop_at(slider_index)

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

func set_selected(option: bool = selected):
	selected = option
	$Note/Path2D/PathFollow2D/SelectedHighlight.visible = selected
	for slider_node in $Sliders.get_children():
		slider_node.set_selected(selected)
