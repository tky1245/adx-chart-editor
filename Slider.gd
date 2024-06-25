extends Node2D
var beat: int
var bpm: float
var slider_property_break: bool
var slider_property_both: bool
var duration_arr: Array = [1, 4]# [x:y]
var duration: float
var delay_arr: Array = [1, 4]
var delay: float
var slider_head_position: String
var slider_shape_arr: Array # contains matches of [shape, target_position, length]

var selected: bool
var position_offset: Vector2

func slider_render(current_time: float) -> void:
	var slide_intro_time = Global.timeline_beats[beat] - Global.note_speed_in_time
	var slide_head_hit_time = Global.timeline_beats[beat]
	var slide_start_time = Global.timeline_beats[beat] + delay
	var slide_end_time = Global.timeline_beats[beat] + delay + duration
	var slider_progress: float
	
	var initial_transparency = 0.5
	var target_transparency = 1
	var initial_scale = 1
	var target_scale = 1.5
	
	var transparency_value
	var scale_value
	if current_time < slide_intro_time: # Not visible
		$SliderArrows.visible = false
		$SliderSegments.visible = false
		slider_progress = 0
		transparency_value = initial_transparency
		scale_value = initial_scale
	elif current_time < slide_head_hit_time: # star appear until star hits
		$SliderArrows.visible = true
		var transparency = (current_time - slide_intro_time - Global.note_speed_in_time * 0.5) / (Global.note_speed_in_time * 0.5) 
		transparency = transparency if transparency >= 0 else 0
		set_node_images_transparency($SliderArrows, transparency)
		set_node_images_transparency($SelectedHighlight, transparency)
		$SliderSegments.visible = false
		slider_progress = 0
		transparency_value = initial_transparency
		scale_value = initial_scale
	elif current_time < slide_start_time: # slider delay
		$SliderArrows.visible = true
		$SliderSegments.visible = true
		var scale_time_start = Global.timeline_beats[beat] + delay * 0.5
		var scale_time_end = slide_start_time
		var progress: float = 0
		if current_time < scale_time_start:
			progress = 0
		elif current_time < scale_time_end:
			progress = (current_time - scale_time_start) / (delay * 0.5)
		else:
			progress = 1
		transparency_value = initial_transparency + (target_transparency - initial_transparency) * progress
		scale_value = initial_scale + (target_scale - initial_scale) * progress
	elif current_time < slide_end_time:	# slider sliding
		$SliderArrows.visible = true
		$SliderSegments.visible = true
		slider_progress = (current_time - Global.timeline_beats[beat] - delay) / duration
		transparency_value = target_transparency
		scale_value = target_scale
	else: # Slide ends
		$SliderArrows.visible = false
		$SliderSegments.visible = false
		slider_progress = 1
		transparency_value = target_transparency
		scale_value = target_scale
	
	for path_holder in $SliderSegments.get_children():
		for path in path_holder.get_children():
			for path_follow in path.get_children():
				for node in path_follow.get_children():
					node.scale = Vector2(scale_value, scale_value)
	set_node_images_transparency($SliderSegments, transparency_value)
	$SelectedHighlight.visible = selected and $SliderArrows.visible
	
	
	for arrow_path in $SliderArrows.get_children():
		for arrow_path_follow in arrow_path.get_children():
			for arrow in arrow_path_follow.get_children(): # Hide arrows when time has passed a threshold
				arrow.visible_toggle(slider_progress)
			var total_distance: float = 0
			for arr in slider_shape_arr: # Calculate total distance
				total_distance += arr[2]
			for i in range(slider_shape_arr.size()): # Move stars along the path
				var elapsed_path_length: float = 0
				if i != 0:
					for j in range(i):
						elapsed_path_length += slider_shape_arr[j][2]
				var path_holder = $SliderSegments.get_child(i)
				var current_path_length = slider_shape_arr[i][2]
				var path_progress: float
				if slider_progress < elapsed_path_length / total_distance:
					path_holder.visible = false
					path_progress = 0
				elif slider_progress < (elapsed_path_length + current_path_length) / total_distance:
					path_progress = (slider_progress * total_distance - elapsed_path_length) / current_path_length
					for path in path_holder.get_children():
						var path_follow = path.get_child(0)
						path_follow.progress_ratio = path_progress
					path_holder.visible = true
				else:
					path_holder.visible = false
					path_progress = 1

func initialize(parent_position: Vector2) -> void: # set up all the shape positions
	set_position_offset(-parent_position)
	set_duration()
	set_delay()
	
	for node in $SliderSegments.get_children(): # Clean up
		node.queue_free()
	# Generate slider segments according to array
	for i in slider_shape_arr.size():
		var new_node = Node2D.new()
		var new_path = Path2D.new()
		var path_curve
		
		if i == 0:
			path_curve = slider_path(slider_shape_arr[i][0], slider_shape_arr[i][1], slider_head_position)
		else:
			path_curve = slider_path(slider_shape_arr[i][0], slider_shape_arr[i][1], slider_shape_arr[i-1][1])
		new_path.curve = path_curve
		$SliderSegments.add_child(new_node)
		new_node.add_child(new_path)
		var path_follow = PathFollow2D.new()
		new_path.add_child(path_follow)
		slider_shape_arr[i][2] = path_curve.get_baked_length() # do length calculation beforehand
		if slider_shape_arr[i][0] == "w": # wifi slider handling, add 2 side star paths
			var target_pos = Global.touch_positions[slider_shape_arr[i][1]]
			var initial_pos = Global.touch_positions[slider_shape_arr[i-1][1]] if i != 0 else Global.touch_positions[slider_head_position]
			var distance = target_pos.distance_to(initial_pos) * cos(TAU/16)
			var relative_pos = target_pos - initial_pos
			var relative_bearing = atan2(relative_pos.y, relative_pos.x)
			var path_left = Path2D.new()
			var curve_left = Curve2D.new()
			if i == 0:
				curve_left.add_point(Global.touch_positions[slider_head_position])
			else:
				curve_left.add_point(Global.touch_positions[slider_shape_arr[i-1][1]])
			curve_left.add_point(initial_pos + distance * Vector2(cos(relative_bearing + TAU/16), sin(relative_bearing + TAU/16)))
			path_left.curve = curve_left
			new_node.add_child(path_left)
			var path_follow_left = PathFollow2D.new()
			path_left.add_child(path_follow_left)
			
			var path_right = Path2D.new()
			var curve_right = Curve2D.new()
			if i == 0:
				curve_right.add_point(Global.touch_positions[slider_head_position])
			else:
				curve_right.add_point(Global.touch_positions[slider_shape_arr[i-1][1]])
			curve_right.add_point(initial_pos + distance * Vector2(cos(relative_bearing - TAU/16), sin(relative_bearing - TAU/16)))
			path_right.curve = curve_right
			new_node.add_child(path_right)
			var path_follow_right = PathFollow2D.new()
			path_right.add_child(path_follow_right)
	# Set color
	var slider_arrow_color_top
	var slider_arrow_color_bottom
	if slider_property_break:
		slider_arrow_color_top = Global.note_colors["slider_top_break"]
		slider_arrow_color_bottom = Global.note_colors["slider_bottom_break"]
	elif slider_property_both:
		slider_arrow_color_top = Global.note_colors["slider_top_both"]
		slider_arrow_color_bottom = Global.note_colors["slider_bottom_both"]
	else:
		slider_arrow_color_top = Global.note_colors["slider_top_base"]
		slider_arrow_color_bottom = Global.note_colors["slider_bottom_base"]
		
	var star_color_inner
	var star_color_outer
	if slider_property_break:
		star_color_inner = Global.note_colors["star_inner_break"]
		star_color_outer = Global.note_colors["star_outer_break"]
	elif slider_property_both:
		star_color_inner = Global.note_colors["star_inner_both"]
		star_color_outer = Global.note_colors["star_outer_both"]
	else:
		star_color_inner = Global.note_colors["star_inner_base"]
		star_color_outer = Global.note_colors["star_outer_base"]
	
	for node in $SliderArrows.get_children():
		node.queue_free()
	# Generate slider arrows from each segments
	var total_distance: float = 0
	for arr in slider_shape_arr: # Calculate total distance
		total_distance += arr[2]
	for idx in range(slider_shape_arr.size()): 
		var i = slider_shape_arr.size() - idx - 1
		var elapsed_distance: float = 0
		if i != 0:
			for j in range(i):
				elapsed_distance += slider_shape_arr[j][2]
		var new_path = Path2D.new()
		var path_curve = $SliderSegments.get_child(i).get_child(0).curve
		new_path.curve = path_curve
		$SliderArrows.add_child(new_path)
		if slider_shape_arr[i][0] != "w":
			var distance: float = 20
			var temp_distance = 0.0
			for j in range(int(slider_shape_arr[i][2] / distance)):
				temp_distance += distance * 0.5
				var new_path_follow = PathFollow2D.new()
				new_path.add_child(new_path_follow)
				new_path_follow.set_progress(temp_distance)
				var slider_arrow = preload("res://note detail stuffs/slider_arrow.tscn")
				var new_arrow = slider_arrow.instantiate()
				var visible_threshold = (temp_distance + elapsed_distance) / total_distance
				new_arrow.set_slider_arrow(slider_arrow_color_top, slider_arrow_color_bottom, visible_threshold)
				new_path_follow.add_child(new_arrow)
				temp_distance += distance * 0.5
		else:
			var distance: float = 33.3
			var temp_distance = 0.0
			for j in range(int(slider_shape_arr[i][2] / distance)):
				if j != 0:
					var new_path_follow = PathFollow2D.new()
					new_path.add_child(new_path_follow)
					new_path_follow.set_progress(temp_distance)
					var slider_arrow = preload("res://note detail stuffs/slider_arrow.tscn")
					var new_arrow = slider_arrow.instantiate()
					var visible_threshold = (temp_distance + elapsed_distance) / total_distance
					var temp_length = slider_shape_arr[i][2] * sin(TAU/16) * (j / (slider_shape_arr[i][2] / distance))
					new_arrow.set_slider_arrow(slider_arrow_color_top, slider_arrow_color_bottom, visible_threshold, true, temp_length)
					new_path_follow.add_child(new_arrow)
				temp_distance += distance
	
	
	# Add stars for each path
	for path_holder in $SliderSegments.get_children():
		for path in path_holder.get_children():
			var path_follow = path.get_child(0)
			var note_star_inner = star(star_color_inner, 4, 15)
			path_follow.add_child(note_star_inner)
			var note_star_outer = star(star_color_outer, 1, 19)
			path_follow.add_child(note_star_outer)
			var note_outline_in = star(Color.WHITE, 1, 10)
			path_follow.add_child(note_outline_in)
			var note_outline_out = star(Color.WHITE, 1, 22)
			path_follow.add_child(note_outline_out)
			var note_outline_out_2 = star(Color.BLACK, 1, 24)
			path_follow.add_child(note_outline_out_2)
	
	# Draw highlight based on existing paths
	var curve: PackedVector2Array = []
	for i in range(slider_shape_arr.size()):
		if i == 0:
			var path_curve = slider_path(slider_shape_arr[i][0], slider_shape_arr[i][1], slider_head_position).get_baked_points()
			curve.append_array(path_curve)
		else:
			var path_curve = slider_path(slider_shape_arr[i][0], slider_shape_arr[i][1], slider_shape_arr[i-1][1]).get_baked_points()
			path_curve.remove_at(0)
			curve.append_array(path_curve)
	for node in $SelectedHighlight.get_children():
		node.queue_free()
	
	var new_curve_arr = Geometry2D.offset_polyline(curve, 20)
	for new_curve in new_curve_arr:
		var highlight_line = Line2D.new()
		highlight_line.closed = true
		highlight_line.width = 3
		highlight_line.default_color = Color.LIME
		
		highlight_line.points = new_curve
		$SelectedHighlight.add_child(highlight_line)
	
	timeline_object_draw()

func timeline_object_draw() -> void:
	var slider_arrow_color_timeline_indicator
	if slider_property_break:
		slider_arrow_color_timeline_indicator = Global.note_colors["slider_indicator_break"]
	elif slider_property_both:
		slider_arrow_color_timeline_indicator = Global.note_colors["slider_indicator_both"]
	else:
		slider_arrow_color_timeline_indicator = Global.note_colors["slider_indicator_base"]
	
	var head_pos = int(slider_head_position) if slider_head_position != "C" else 8
	$TimelineIndicator.position = Vector2(0, 15 * int(head_pos) + 510) - Global.preview_center
	for node in $TimelineIndicator.get_children():
		node.free()
	var line_node = arrow_line(slider_arrow_color_timeline_indicator, duration * Global.timeline_pixels_to_second * Global.timeline_zoom)
	$TimelineIndicator.add_child(line_node)
	var indicator_highlight = Line2D.new()
	var poly = Geometry2D.offset_polygon([Vector2(0, -3), Vector2(0, 3), Vector2(duration * Global.timeline_pixels_to_second * Global.timeline_zoom, 3), Vector2(duration * Global.timeline_pixels_to_second * Global.timeline_zoom, -3)],4)[0]
	indicator_highlight.name = "IndicatorHighlight"
	indicator_highlight.points = poly
	indicator_highlight.closed = true
	indicator_highlight.default_color = Color.LIME
	indicator_highlight.width = 2
	$TimelineIndicator.add_child(indicator_highlight)

func set_duration(arr: Array = duration_arr) -> void:
	duration_arr = arr
	if duration_arr[1] == 0:
		duration = duration_arr[0]
	else:
		duration = 60.0 * Global.beats_per_bar / bpm * (float(duration_arr[0]) / duration_arr[1])

func set_delay(arr: Array = delay_arr) -> void:
	delay_arr = arr
	if delay_arr[1] == 0:
		delay = delay_arr[0]
	else:
		delay = 60.0 * Global.beats_per_bar / bpm * (float(delay_arr[0]) / delay_arr[1])

func set_position_offset(offset = position_offset):
	position_offset = offset
	position = position_offset

func timeline_object_render() -> void:
	var time_1 = Global.timeline_beats[beat] + delay
	var time_2 = time_1 + duration
	if time_2 > Global.timeline_visible_time_range["Start"] and time_1 < Global.timeline_visible_time_range["End"]:
		$TimelineIndicator.visible = true
		$TimelineIndicator.position.x = Global.time_to_timeline_pos_x(time_1) - Global.preview_center.x
	else:
		$TimelineIndicator.visible = false

func slider_path(shape: String, target_note_position: String, initial_note_position: String) -> Curve2D:
	var curve = Curve2D.new()
	var initial_position = Global.touch_positions[initial_note_position]
	var target_position = Global.touch_positions[target_note_position]
	curve.add_point(Vector2(initial_position)) # from previous pos
	if shape == "-" or shape == "w": # straight line, ezpz
		curve.add_point(Vector2(target_position))
	elif shape == "<":
		var radius_start = Vector2(initial_position).distance_to(Vector2(0, 0))
		var radius_end = Vector2(target_position).distance_to(Vector2(0, 0))
		var angle_1 = atan2(initial_position.y, initial_position.x)
		var angle_2 = atan2(target_position.y, target_position.x)
		var frequency: int = 360
		if int(initial_note_position) in [1, 2, 7, 8]: # ccw
			var total_angle = angle_1 - angle_2
			while total_angle < 0:
				total_angle += TAU
			for i in range(total_angle / TAU * frequency):
				var radius = radius_start + (radius_end - radius_start) * i
				var point_angle = angle_1 - i * TAU / frequency 
				curve.add_point(radius * Vector2(cos(point_angle), sin(point_angle)))
		elif int(initial_note_position) in [3, 4, 5, 6]: # cw
			var total_angle = angle_2 - angle_1
			if total_angle < 0:
				total_angle += TAU
			for i in range(total_angle / TAU * frequency):
				var radius = radius_start + (radius_end - radius_start) * i
				var point_angle = angle_1 + i * TAU / frequency 
				curve.add_point(radius * Vector2(cos(point_angle), sin(point_angle)))
	elif shape == ">": # we do a bit of copy pasta
		var radius_start = Vector2(initial_position).distance_to(Vector2(0, 0))
		var radius_end = Vector2(target_position).distance_to(Vector2(0, 0))
		var angle_1 = atan2(initial_position.y, initial_position.x)
		var angle_2 = atan2(target_position.y, target_position.x)
		var frequency: int = 360
		if int(initial_note_position) in [3, 4, 5, 6]: # ccw
			var total_angle = angle_1 - angle_2
			while total_angle < 0:
				total_angle += TAU
			for i in range(total_angle / TAU * frequency):
				var radius = radius_start + (radius_end - radius_start) * i
				var point_angle = angle_1 - i * TAU / frequency 
				curve.add_point(radius * Vector2(cos(point_angle), sin(point_angle)))
		elif int(initial_note_position) in [1, 2, 7, 8]: # cw
			var total_angle = angle_2 - angle_1
			if total_angle < 0:
				total_angle += TAU
			for i in range(total_angle / TAU * 360):
				var radius = radius_start + (radius_end - radius_start) * i
				var point_angle = angle_1 + i * TAU / frequency 
				curve.add_point(radius * Vector2(cos(point_angle), sin(point_angle)))
	elif shape == "v": 
		curve.add_point(Vector2(0, 0))
		curve.add_point(Vector2(target_position))
	elif shape == "s":
		var head_bearing = atan2(Global.touch_positions[slider_head_position].x, -Global.touch_positions[slider_head_position].y)
		curve.add_point(Global.preview_radius * tan(PI / 8) * Vector2(sin(head_bearing - TAU / 4), -cos(head_bearing - TAU / 4)))
		curve.add_point(Global.preview_radius * tan(PI / 8) * Vector2(sin(head_bearing + TAU / 4), -cos(head_bearing + TAU / 4)))
		curve.add_point(Vector2(target_position))
	elif shape == "z":
		var head_bearing = atan2(Global.touch_positions[slider_head_position].x, -Global.touch_positions[slider_head_position].y)
		curve.add_point(Global.preview_radius * tan(PI / 8) * Vector2(sin(head_bearing + TAU / 4), -cos(head_bearing + TAU / 4)))
		curve.add_point(Global.preview_radius * tan(PI / 8) * Vector2(sin(head_bearing - TAU / 4), -cos(head_bearing - TAU / 4)))
		curve.add_point(Vector2(target_position))
	elif shape == "p": # ccw
		var circle_radius = Global.preview_radius * sin(TAU / 16)
		var intro_distance = initial_position.distance_to(Vector2(0, 0))
		var intro_tangent_bearing = atan2(initial_position.y, initial_position.x) - abs(acos(circle_radius / intro_distance))
		var outro_distance = target_position.distance_to(Vector2(0, 0))
		var outro_tangent_bearing = atan2(target_position.y, target_position.x) + abs(acos(circle_radius / outro_distance))
		var frequency: int = 360
		var total_angle = intro_tangent_bearing - outro_tangent_bearing
		while total_angle < TAU/16:
			total_angle += TAU
		for i in range(total_angle / TAU * frequency):
			var point_angle = intro_tangent_bearing - i * TAU / frequency 
			curve.add_point(circle_radius * Vector2(cos(point_angle), sin(point_angle)))
		curve.add_point(Vector2(target_position))
	elif shape == "q": # cw
		var circle_radius = Global.preview_radius * sin(TAU / 16)
		var intro_distance = initial_position.distance_to(Vector2(0, 0))
		var intro_tangent_bearing = atan2(initial_position.y, initial_position.x) + abs(acos(circle_radius / intro_distance))
		var outro_distance = target_position.distance_to(Vector2(0, 0))
		var outro_tangent_bearing = atan2(target_position.y, target_position.x) - abs(acos(circle_radius / outro_distance))
		var frequency: int = 360
		var total_angle = - intro_tangent_bearing + outro_tangent_bearing
		while total_angle < TAU/16:
			total_angle += TAU
		for i in range(total_angle / TAU * frequency):
			var point_angle = intro_tangent_bearing + i * TAU / frequency 
			curve.add_point(circle_radius * Vector2(cos(point_angle), sin(point_angle)))
		curve.add_point(Vector2(target_position))
	elif shape == "pp": # ccw
		var circle_radius = (Global.preview_radius - 14.0) / 2
		var initial_bearing = atan2(initial_position.y, initial_position.x)
		var circle_center = circle_radius * Vector2(cos(initial_bearing + TAU*3/16), sin(initial_bearing + TAU*3/16))
		var intro_tangent_bearing = initial_bearing - TAU/4
		var outro_relative_angle = abs(acos(circle_radius / target_position.distance_to(circle_center)))
		var outro_tangent_bearing = atan2(Vector2(target_position - circle_center).y, Vector2(target_position - circle_center).x) + outro_relative_angle
		var total_angle = intro_tangent_bearing - outro_tangent_bearing
		var frequency = 360
		
		while total_angle < TAU/4:
			total_angle += TAU
		for i in range(total_angle / TAU * frequency):
			var point_angle = intro_tangent_bearing - i * TAU / frequency 
			curve.add_point(circle_center + circle_radius * Vector2(cos(point_angle), sin(point_angle)))
		curve.add_point(Vector2(target_position))
	elif shape == "qq": # cw
		var circle_radius = (Global.preview_radius - 14.0) / 2
		var initial_bearing = atan2(initial_position.y, initial_position.x)
		var circle_center = circle_radius * Vector2(cos(initial_bearing - TAU*3/16), sin(initial_bearing - TAU*3/16))
		var intro_tangent_bearing = initial_bearing + TAU/4
		var outro_relative_angle = abs(acos(circle_radius / target_position.distance_to(circle_center)))
		var outro_tangent_bearing = atan2(Vector2(target_position - circle_center).y, Vector2(target_position - circle_center).x) - outro_relative_angle
		var total_angle = -intro_tangent_bearing + outro_tangent_bearing
		var frequency = 360
		while total_angle < TAU/4:
			total_angle += TAU
		for i in range(total_angle / TAU * frequency):
			var point_angle = intro_tangent_bearing + i * TAU / frequency 
			curve.add_point(circle_center + circle_radius * Vector2(cos(point_angle), sin(point_angle)))
		curve.add_point(Vector2(target_position))
	return curve
		
func star(color: Color, width: float,  radius: float = 18) -> Line2D: # star tap
	var newLine = Line2D.new()
	newLine.default_color = color
	newLine.width = width
	newLine.closed = true
	newLine.sharp_limit = 999
	for i in range(5):
		newLine.add_point(Vector2(cos(i * TAU / 5), sin(i * TAU / 5)) * radius)
		newLine.add_point(Vector2(cos((i * 2 + 1) * TAU / 10), sin((i * 2 + 1) * TAU / 10)) * radius * 1.3 * sin(deg_to_rad(18) / sin(deg_to_rad(126))))
	return newLine

func arrow_line(color: Color, distance: float) -> Node2D:
	var new_node = Node2D.new()
	var temp_distance = 0
	while distance > temp_distance:
		temp_distance += 4
		var new_line = Line2D.new()
		new_line.default_color = color
		new_line.width = 1
		new_line.add_point(Vector2(-3 + temp_distance, 3))
		new_line.add_point(Vector2(0 + temp_distance, 0))
		new_line.add_point(Vector2(-3 + temp_distance, -3))
		new_node.add_child(new_line)
		
	return new_node
	
func set_node_images_transparency(node: Node2D, transparency: float) -> void:
	if node.get_children().size() == 0:
		node.self_modulate.a = transparency
	else:
		for child_node in node.get_children():
			set_node_images_transparency(child_node, transparency)

func set_selected(option: bool):
	selected = option
	$TimelineIndicator/IndicatorHighlight.visible = selected

func select_area() -> Array:
	var arr: Array = []
	if $SliderArrows.visible:
		var note_selected_highlight_arr: Array[PackedVector2Array] = []
		for line in $SelectedHighlight.get_children():
			note_selected_highlight_arr.append(line.points * Transform2D(0.0, -$SelectedHighlight.global_position))
		arr.append(note_selected_highlight_arr)
	if $TimelineIndicator.visible:
		var indicator_highlight = $TimelineIndicator/IndicatorHighlight
		arr.append(indicator_highlight.points * Transform2D(0.0, -indicator_highlight.global_position))
	return arr
