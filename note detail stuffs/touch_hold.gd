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

var selected: bool

func preview_render(current_time: float) -> void:
	note_render(current_time)
	slider_render(current_time)

func note_render(current_time: float) -> void:
	if note_property_touch: # touch hold logic
		var intro_time: float = Global.timeline_beats[beat] - Global.note_speed_in_time
		var move_time: float = Global.timeline_beats[beat] - Global.note_speed_in_time * 0.7
		var judge_start: float = Global.timeline_beats[beat]
		var judge_end: float = Global.timeline_beats[beat] + duration
		
		var intro_progress: float = 0
		var path_progress: float = 0
		var hold_progress: float = 0
		
		var radius = 6
		var distance = 27
		var polygon = petal_polygon(distance, radius)	

		if current_time < intro_time:
			$Note.visible = false
			intro_progress = 0
			path_progress = 0
			hold_progress = 0
		elif current_time < move_time:
			$Note.visible = true
			intro_progress = (current_time - intro_time) / (move_time - intro_time)
			path_progress = 0
			hold_progress = 0
		elif current_time < judge_start:
			$Note.visible = true
			intro_progress = 1
			path_progress = (current_time - move_time) / (judge_start - move_time)
			hold_progress = 0
		elif current_time < judge_end:
			$Note.visible = true
			intro_progress = 1
			path_progress = 1
			hold_progress = (current_time - judge_start) / duration
		else:
			$Note.visible = false
			intro_progress = 1
			path_progress = 1
			hold_progress = 1
		
		for i in range(4):
			var note_pathfollow = $Note/Segments.get_child(i).get_child(0).get_child(0)
			for node in note_pathfollow.get_children():
				node.self_modulate.a = intro_progress	
			note_pathfollow.progress_ratio = path_progress
		for node in $Note/CenterDot.get_children():
			node.self_modulate.a = intro_progress
		
		if hold_progress == 0.0:
			for node in $Note/ProgressCircle.get_children():
				node.visible = false
		else:
			for i in range(4):
				var progress_circle_polygon = $Note/ProgressCircle.get_child(i)
				var n = int(hold_progress * 4)
				progress_circle_polygon.self_modulate.a = intro_progress
				if i < n:
					progress_circle_polygon.polygon = polygon
					progress_circle_polygon.visible = true
				elif i == n:
					progress_circle_polygon.visible = true
					var angle = TAU / 4 - (hold_progress * 4 - n) * TAU / 4
					progress_circle_polygon.polygon = reshape(polygon, angle, )
				else:
					progress_circle_polygon.visible = false
		
		# Selected Highlight
		var new_polygon: PackedVector2Array = []
		for i in range(4):
			var poly = petal_polygon(39-17*path_progress, 6)
			new_polygon.append_array(poly * Transform2D(i*TAU/4, Vector2(0, 0)))
		$Note/SelectedHighlight.points = Geometry2D.offset_polygon(new_polygon, 10)[0]

func slider_render(current_time: float) -> void:
	for slider in $Sliders.get_children():
		slider.slider_render(current_time)

func initialize() -> void:
	set_duration()
	set_note_position()
	touch_hold_draw()


func set_duration(arr: Array = duration_arr) -> void:
	duration_arr = arr
	if duration_arr[1] == 0:
		duration = duration_arr[0]
	else:
		duration = 60.0 * Global.beats_per_bar / bpm * (float(duration_arr[0]) / duration_arr[1])

func set_note_position(pos: String = note_position) -> void:
	note_position = pos
	$Note.position = Global.preview_center + Global.touch_positions[note_position]

func touch_hold_draw() -> void:
	for node in $Note/ProgressCircle.get_children():
		node.queue_free()
	for i in range(4): # Progress bar
		var petal = Polygon2D.new()
		petal.name = "Petal" + str(i)
		petal.color = Global.note_colors["touch_hold_" + str(i + 1)]
		var radius = 6
		var distance = 27
		petal.polygon = petal_polygon(distance, radius)
		petal.rotation = i * TAU / 4
		$Note/ProgressCircle.add_child(petal)
	for i in range(4): # 4 segments
		var note_path = $Note/Segments.get_child(i).get_child(0)
		var note_pathfollow = note_path.get_child(0)
		for node in note_pathfollow.get_children():
			node.queue_free()
		var angle = TAU / 4 * i - 3 * TAU / 8
		note_path.rotation = PI
		note_path.curve = Curve2D.new()
		note_path.curve.add_point(17 * Vector2(sin(angle), -cos(angle)))
		note_path.curve.add_point(Vector2(0, 0))
		
		var petal = Polygon2D.new()
		petal.color = Global.note_colors["touch_hold_" + str(i + 1)]
		var radius = 6
		var distance = 22
		petal.polygon = petal_polygon(distance, radius)
		petal.rotation = 5 * TAU / 8
		note_pathfollow.add_child(petal)
		
		var petal_outline = Line2D.new()
		petal_outline.default_color = Color.BLACK
		petal_outline.width = 1
		petal_outline.closed = true
		for point in petal.polygon:
			petal_outline.add_point(point)
		petal_outline.rotation = 5 * TAU / 8
		note_pathfollow.add_child(petal_outline)

	for node in $Note/CenterDot.get_children():
		node.queue_free()
	var center_dot = Polygon2D.new()
	center_dot.color = Global.note_colors["touch_hold_center"]
	var polygon_points: PackedVector2Array = []
	var frequency = 8
	for i in range(frequency):
		var angle = i * TAU / frequency
		polygon_points.append(Vector2(5, 0).rotated(angle))
	center_dot.polygon = polygon_points
	$Note/CenterDot.add_child(center_dot)
	var center_dot_outline = Line2D.new()
	center_dot_outline.default_color = Color.BLACK
	center_dot_outline.width = 1
	center_dot_outline.closed = true
	for i in range(frequency):
		var angle = i * TAU / frequency
		center_dot_outline.add_point(Vector2(5, 0).rotated(angle))
	$Note/CenterDot.add_child(center_dot_outline)
	if sliders.size() != 0:
		pass

	# Timeline
	for node in $TimelineIndicator.get_children():
		node.free()
	for i in range(4):
		var color = Global.note_colors["touch_hold_" + str(i+1)]
		var new_line = Line2D.new()
		var point_1 = Vector2(i / 4.0 * duration * Global.timeline_pixels_to_second, 0)
		var point_2 = Vector2((i + 1) / 4.0 * duration * Global.timeline_pixels_to_second, 0)
		var note_pos = int(note_position) if note_position != "C" else 8
		new_line.add_point(point_1)
		new_line.add_point(point_2)
		new_line.default_color = color
		new_line.width = 8
		new_line.position = Vector2(0, 15 * note_pos - 6)
		$TimelineIndicator.add_child(new_line)
	
	$Note/SelectedHighlight.default_color = Color.LIME
	

func timeline_object_render() -> void: #TODO change visible range
	var time_1 = Global.timeline_beats[beat]
	var time_2 = time_1 + duration
	if time_2 > Global.timeline_visible_time_range["Start"] and time_1 < Global.timeline_visible_time_range["End"]:
		$TimelineIndicator.visible = true
		$TimelineIndicator.position = Vector2(Global.time_to_timeline_pos_x(time_1), 516)
	else:
		$TimelineIndicator.visible = false

func petal_polygon(distance: float, radius: float) -> PackedVector2Array:
	var frequency = 30
	var polygon_points: PackedVector2Array = []
	polygon_points.append(Vector2(0, 0))
	for k in range(frequency+1):
		var angle = k * TAU / 8 / frequency
		polygon_points.append((Vector2(0, -distance) + Vector2(sin(angle), -cos(angle)) * radius))
	var point_1 = Vector2(0, -distance) + Vector2(sin(TAU / 8), -cos(TAU / 8)) * radius
	var point_2 = Vector2(distance, 0) + Vector2(sin(TAU / 8), -cos(TAU / 8)) * radius
	var dpoint: Vector2 = point_2 - point_1
	for k in range(frequency-1):
		polygon_points.append(point_1 + dpoint / frequency * (k+1))
	for k in range(frequency+1):
		var angle = k * TAU / 8 / frequency + TAU / 8
		polygon_points.append((Vector2(distance, 0) + Vector2(sin(angle), -cos(angle)) * radius))
	return polygon_points

func reshape(petal: PackedVector2Array, angle: float, point_sign: int = 1) -> PackedVector2Array:
	var new_polygon: PackedVector2Array = []
	var m: float
	var vertical = false
	if abs(angle - TAU / 4) < 1e-6:
		return new_polygon
	# Handle the special case when the angle is 1/4 TAU
	if abs(angle - TAU / 4) < 1e-6:
		vertical = true
	else:
		m = -tan(angle)
	
	for i in range(petal.size()):
		var x0 = petal[i].x
		var y0 = petal[i].y
		var x1 = petal[(i + 1) % petal.size()].x
		var y1 = petal[(i + 1) % petal.size()].y

		var side0: float
		var side1: float

		if vertical:
			side0 = x0
			side1 = x1
		else:
			side0 = m * x0 - y0
			side1 = m * x1 - y1

		if (side0 * point_sign) >= 0:
			new_polygon.append(Vector2(x0, y0))

		if (side0 * side1) < 0: # Edge crosses the cutting line
			if vertical:
				var intersect_x = 0.0
				var intersect_y = y0 + (0.0 - x0) * (y1 - y0) / (x1 - x0)
				var _new_point = Vector2(intersect_x, intersect_y)
			else:
				var a1 = y1 - y0
				var b1 = x0 - x1
				var c1 = y0 * (x0 - x1) - x1 * (y1 - y0)
				var a2 = m
				var b2 = -1.0
				var c2 = 0.0
				var denominator = a1 * b2 - a2 * b1
				
				if abs(denominator) > 1e-6: # Avoid division by zero
					var intersect_x = abs((b1 * c2 - b2 * c1) / denominator)
					var intersect_y = -abs((a2 * c1 - a1 * c2) / denominator)
					var new_point = Vector2(intersect_x, intersect_y)
					new_polygon.append(new_point)
	return new_polygon

func set_selected(option: bool = selected):
	selected = option
	$Note/SelectedHighlight.visible = selected
	for slider_node in $Sliders.get_children():
		slider_node.set_selected(selected)
