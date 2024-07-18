extends Node2D


var intro_progress: float
var progress: float
var effect_color = Color.YELLOW

var hexagon_status: Array[Dictionary] = []

func _ready():
	hit_trigger()

# remember to add the fade in
# touch hold release also uses this effect
func _process(delta):
	progress += delta / 0.25
	if progress > 1.5:
		queue_free()
	if intro_progress < 1:
		intro_progress += delta / 0.15
		self_modulate.a = intro_progress
	for i in range(5):
		var offset: float = 0
		var shape_scale: float = 0
		if i == 0:
			scale = Vector2(0.5+0.5*intro_progress, 0.5+0.5*intro_progress)
		else:
			offset = 35
			if hexagon_status[i]["direction"]:
				hexagon_status[i]["bearing"] -= delta / 0.25 * 3.0 / 4.0 * TAU
			else:
				hexagon_status[i]["bearing"] += delta / 0.25 * 3.0 / 4.0 * TAU
			if progress > 0.5:
				offset = 35 * pow(1 - (progress - 0.5) * 2, 0.5)
		if i == 0:
			shape_scale = 0.6
		elif i == 1 or i == 2:
			shape_scale = 0.15
		else:
			shape_scale = 0.4
		
		var shape = get_child(i)
		shape.position = Vector2(offset, 0).rotated(hexagon_status[i]["bearing"])
		if progress > 1:
			shape.self_modulate.a = (1 - (progress - 1 + i * 0.05) * 5)
		else:
			shape.scale = Vector2(1, 1) - (Vector2(1, 1) - Vector2(shape_scale, shape_scale)) * pow(1 - progress, 0.5)
		
func hit_trigger():
	self_modulate.a = 0
	intro_progress = 0
	progress = 0
	hexagon_status = []
	for node in get_children():
		node.free()
	for i in range(5):
		add_child(hexagon())
	hexagon_status.append({
		"scale": 0.5,
		"bearing": 0,
		"direction": CLOCKWISE,
	})
	hexagon_status.append({
		"scale": 0.25,
		"bearing": 0,
		"direction": CLOCKWISE,
	})
	hexagon_status.append({
		"scale": 0.25,
		"bearing": PI,
		"direction": CLOCKWISE,
	})
	hexagon_status.append({
		"scale": 0.375,
		"bearing": 0,
		"direction": COUNTERCLOCKWISE,
	})
	hexagon_status.append({
		"scale": 0.375,
		"bearing": PI,
		"direction": COUNTERCLOCKWISE,
	})

func hexagon(size: float = 32) -> Line2D:
	var new_line = Line2D.new()
	for i in range(6):
		new_line.add_point(Vector2(0, size).rotated(i * TAU / 6))
	new_line.closed = true
	new_line.default_color = effect_color
	new_line.width = 3
	return new_line
	
