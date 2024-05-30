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
	if note_property_touch: # touch hold logic
		var fade_progress: float = 0
		var intro_progress: float = 0
		var hold_progress: float = 0
		var radius = 6
		var distance = 27
		var polygon = petal_polygon(distance, radius)	
		var time_1 = Global.timeline_beats[beat]
		var time_2 = time_1 + 60.0 * Global.beats_per_bar / bpm * (duration_x / duration_y)
		if current_time < time_1 - Global.note_speed_in_time or current_time > time_2:
			$Preview.visible = false
			for path in $Preview/NoteShape/Petals.get_children():
				path.get_child(0).progress_ratio = 0
		else:
			$Preview.visible = true
			if current_time >= time_1 - Global.note_speed_in_time and current_time < time_1 - 0.7 * Global.note_speed_in_time:
				intro_progress = 0
				fade_progress = (current_time - (time_1 - Global.note_speed_in_time)) / (0.3 * Global.note_speed_in_time)
				hold_progress = 0
			elif current_time >= current_time - 0.7 * Global.note_speed_in_time and current_time < time_1:
				fade_progress = 1
				intro_progress = (current_time - (time_1 - 0.7 * Global.note_speed_in_time)) / (0.7 * Global.note_speed_in_time)
				hold_progress = 0
			elif current_time > time_1 and current_time < time_2:
				fade_progress = 1
				intro_progress = 1
				hold_progress = (current_time - time_1) / (time_2 - time_1)
			
			for path in $Preview/NoteShape/Petals.get_children():
				path.get_child(0).progress_ratio = intro_progress
				for node in path.get_child(0).get_children():
					node.self_modulate.a = fade_progress
					
			var n = int(hold_progress * 4)
			if hold_progress == 0.0:
				for node in $Preview/NoteShape/ProgressCircle.get_children():
					node.visible = false
			else:
				for i in range(4):
					$Preview/NoteShape/ProgressCircle.get_child(i).self_modulate.a = fade_progress
					if i < n:
						$Preview/NoteShape/ProgressCircle.get_child(i).polygon = polygon
						$Preview/NoteShape/ProgressCircle.get_child(i).visible = true
					elif i == n:
						$Preview/NoteShape/ProgressCircle.get_child(i).visible = true
						var angle = TAU / 4 - (hold_progress * 4 - n) * TAU / 4
						$Preview/NoteShape/ProgressCircle.get_child(i).polygon = reshape(polygon, angle, )
					else:
						$Preview/NoteShape/ProgressCircle.get_child(i).visible = false
			for node in $Preview/NoteShape/CenterDot.get_children():
				node.self_modulate.a = fade_progress
				
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
				line = hexagon_shape(start_point, start_point, 18, line)
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
				hexagon_shape(start_point, end_point, 18, line)
			$Preview.visible = true

func initialize() -> void:
	for node in $Preview.get_children():
		node.free()
	if note_property_touch: # touch hold logic
		var new_node = Node2D.new()
		new_node.name = "NoteShape"
		$Preview.add_child(new_node)
		
		var progress_circle_node = Node2D.new()
		progress_circle_node.name = "ProgressCircle"
		progress_circle_node.position = Global.touch_positions[note_position]
		$Preview/NoteShape.add_child(progress_circle_node)
		for i in range(4):
			var petal = Polygon2D.new()
			petal.name = "Petal" + str(i)
			petal.color = Global.note_colors["touch_hold_" + str(i + 1)]
			var radius = 6
			var distance = 27
			petal.polygon = petal_polygon(distance, radius)
			petal.rotation = i * TAU / 4
			
			$Preview/NoteShape/ProgressCircle.add_child(petal)
		
		var petals = Node2D.new()
		petals.name = "Petals"
		$Preview/NoteShape.add_child(petals)
		for i in range(4):
			var path = Path2D.new()
			var angle = TAU / 4 * i - 3 * TAU / 8
			path.name = "Path" + str(i)
			$Preview/NoteShape/Petals.add_child(path)
			$Preview/NoteShape/Petals.get_child(i).position = Global.touch_positions[note_position]
			$Preview/NoteShape/Petals.get_child(i).rotation = PI
			var path_follow = PathFollow2D.new()
			path_follow.name = "PathFollow"
			path.add_child(path_follow)
			path.curve = Curve2D.new()
			path.curve.add_point(17 * Vector2(sin(angle), -cos(angle)))
			path.curve.add_point(Vector2(0, 0))
			
			var petal = Polygon2D.new()
			petal.color = Global.note_colors["touch_hold_" + str(i + 1)]
			var radius = 6
			var distance = 22
			petal.polygon = petal_polygon(distance, radius)
			petal.rotation = 5 * TAU / 8
			path_follow.add_child(petal)
			
			var petal_outline = Line2D.new()
			petal_outline.default_color = Color.BLACK
			petal_outline.width = 1
			petal_outline.closed = true
			for point in petal.polygon:
				petal_outline.add_point(point)
			petal_outline.rotation = 5 * TAU / 8
			path_follow.add_child(petal_outline)
		
		var dot_note = Node2D.new()
		dot_note.name = "CenterDot"
		dot_note.position = Global.touch_positions[note_position]
		$Preview/NoteShape.add_child(dot_note)
		var center_dot = Polygon2D.new()
		center_dot.color = Global.note_colors["touch_hold_center"]
		var polygon_points: PackedVector2Array = []
		var frequency = 8
		for i in range(frequency):
			var angle = i * TAU / frequency
			polygon_points.append(Vector2(5, 0).rotated(angle))
			print(angle)
		center_dot.polygon = polygon_points
		$Preview/NoteShape/CenterDot.add_child(center_dot)
		var center_dot_outline = Line2D.new()
		center_dot_outline.default_color = Color.BLACK
		center_dot_outline.width = 1
		center_dot_outline.closed = true
		for i in range(frequency):
			var angle = i * TAU / frequency
			center_dot_outline.add_point(Vector2(5, 0).rotated(angle))
		$Preview/NoteShape/CenterDot.add_child(center_dot_outline)
		
		for node in $TimelineIndicator.get_children():
			node.free()
		for i in range(4):
			var color = Global.note_colors["touch_hold_" + str(i+1)]
			var new_line = Line2D.new()
			var point_1 = Vector2(i / 4.0 * 60.0 * Global.beats_per_bar / bpm * (duration_x / duration_y) * Global.timeline_pixels_to_second, 0)
			var point_2 = Vector2((i + 1) / 4.0 * 60.0 * Global.beats_per_bar / bpm * (duration_x / duration_y) * Global.timeline_pixels_to_second, 0)
			var note_pos = int(note_position) if note_position != "C" else 8
			new_line.add_point(point_1)
			new_line.add_point(point_2)
			new_line.default_color = color
			new_line.width = 8
			new_line.position = Vector2(0, 15 * note_pos - 6)
			$TimelineIndicator.add_child(new_line)
		
	else: # hold logic
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
		
		for node in $TimelineIndicator.get_children():
			node.free()

		var new_hexagon = hexagon_shape(Vector2(0, 0), Vector2((60.0 * Global.beats_per_bar / bpm * (duration_x / duration_y)) * Global.timeline_pixels_to_second, 0), 4, null, 0)
		new_hexagon.default_color = note_color
		new_hexagon.width = 2
		new_hexagon.position = Vector2(0, 15 * int(note_position) - 6)
		$TimelineIndicator.add_child(new_hexagon)
		
func timeline_object_render() -> void: #TODO change visible range
	var time_1 = Global.timeline_beats[beat]
	var time_2 = time_1 + 60.0 * Global.beats_per_bar / bpm * (duration_x / duration_y)
	if time_2 > Global.timeline_visible_time_range["Start"] and time_1 < Global.timeline_visible_time_range["End"]:
		$TimelineIndicator.visible = true
		$TimelineIndicator.position = Vector2(Global.time_to_timeline_pos_x(time_1), 516)
	else:
		$TimelineIndicator.visible = false

func hexagon_shape(point_1: Vector2, point_2: Vector2, radius: float = 18, hexagon: Line2D = null, angle: float = ((int(note_position) * 2 - 1) * TAU / 16) + TAU / 4) -> Line2D:
	if !hexagon:
		var new_line = Line2D.new()
		new_line.closed = true
		new_line.add_point(point_1 + Vector2(-radius, 0).rotated(angle - TAU / 6))
		new_line.add_point(point_1 + Vector2(-radius, 0).rotated(angle))
		new_line.add_point(point_1 + Vector2(-radius, 0).rotated(angle + TAU / 6))
		new_line.add_point(point_2 + Vector2(-radius, 0).rotated(angle + 2 * TAU / 6))
		new_line.add_point(point_2 + Vector2(-radius, 0).rotated(angle + 3 * TAU / 6))
		new_line.add_point(point_2 + Vector2(-radius, 0).rotated(angle + 4 * TAU / 6))
		return new_line
	else:
		hexagon.set_point_position(0, point_1 + Vector2(-radius, 0).rotated(angle - TAU / 6))
		hexagon.set_point_position(1, point_1 + Vector2(-radius, 0).rotated(angle))
		hexagon.set_point_position(2, point_1 + Vector2(-radius, 0).rotated(angle + TAU / 6))
		hexagon.set_point_position(3, point_2 + Vector2(radius, 0).rotated(angle - TAU / 6))
		hexagon.set_point_position(4, point_2 + Vector2(radius, 0).rotated(angle))
		hexagon.set_point_position(5, point_2 + Vector2(radius, 0).rotated(angle + TAU / 6))
		return hexagon

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

func reshape(petal: PackedVector2Array, angle: float, sign: int = 1) -> PackedVector2Array:
	var new_polygon: PackedVector2Array = []
	var m: float
	var vertical = false

	# Handle the special case when the angle is 1/4 TAU
	if abs(angle - TAU / 4) < 1e-6:
		vertical = true
		print("Handling vertical line case.")
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

		if (side0 * sign) >= 0:
			new_polygon.append(Vector2(x0, y0))

		if (side0 * side1) < 0: # Edge crosses the cutting line
			if vertical:
				var intersect_x = 0.0
				var intersect_y = y0 + (0.0 - x0) * (y1 - y0) / (x1 - x0)
				var new_point = Vector2(intersect_x, intersect_y)
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
	print("angle: ", angle, ", point count: ", new_polygon)
	return new_polygon
