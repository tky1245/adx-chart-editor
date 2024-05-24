extends Node2D
var beat: int
var note_property_break: bool
var note_property_ex: bool
var note_property_touch: bool
var note_property_firework: bool
var note_property_both: bool
var note_position: String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.

func shape_update(): # um
	pass
	
func preview_render(current_time):
	if current_time < Global.timeline_beats[beat] - Global.note_speed_in_time or current_time > Global.timeline_beats[beat]:
		$Preview.visible = false
	else:
		$Preview.visible = true
		
		var progress = (current_time - Global.timeline_beats[beat] + Global.note_speed_in_time) / Global.note_speed_in_time
		# 0.3 growing 0.7 moving
		if progress <= 0.3:
			$Preview/NotePath/NotePathFollow/NoteShape.scale = Vector2(progress/0.3,progress/0.3)
			$Preview/NotePath/NotePathFollow/NoteShape.self_modulate.a = progress/0.3
		else:
			$Preview/NotePath/NotePathFollow/NoteShape.scale = Vector2(1, 1)
			$Preview/NotePath/NotePathFollow/NoteShape.self_modulate.a = 1
			$Preview/NotePath/NotePathFollow.progress_ratio = (progress - 0.3) / 0.7


func circle(color: Color, width: float):
	var newLine = Line2D.new()
	newLine.default_color = color
	newLine.width = width
	for i in range(361):
		var angle = i * PI / 180
		const radius = 18
		newLine.add_point(Vector2(radius * sin(angle), radius * cos(angle)))
	return newLine
	
func tap_initialize(pos: String = note_position):
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
	print(pos)
	print(note_pos)
	var angle = (note_pos * 2 - 1) * TAU / 16
	var new_curve = Curve2D.new()
	var start_point = Global.preview_center + Vector2(Global.initial_note_distance * sin(angle), -Global.initial_note_distance * cos(angle))
	new_curve.add_point(start_point)
	var end_point = Global.preview_center + Vector2(Global.preview_radius * sin(angle), -Global.preview_radius * cos(angle))
	new_curve.add_point(end_point)
	$Preview/NotePath.curve = new_curve


func touch_initialize():
	pass
