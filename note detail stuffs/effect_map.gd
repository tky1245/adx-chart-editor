extends Node2D

# Clip children doesnt work

func _ready():
	var poly: PackedVector2Array = []
	for i in range(180):
		poly.append(Vector2(250, 0).rotated(i*TAU/180))
	$Circle.polygon = poly
	
	for i in range(8): # A1-A8
		var effect_generator = preload("res://note detail stuffs/effect_generator.tscn")
		var new_effect_generator = effect_generator.instantiate()
		new_effect_generator.position = Global.touch_positions["A" + str(i+1)]
		new_effect_generator.note_position = "A" + str(i+1)
		$Circle/EffectGenerators.add_child(new_effect_generator)
		
	for i in range(8): # B1-B8
		var effect_generator = preload("res://note detail stuffs/effect_generator.tscn")
		var new_effect_generator = effect_generator.instantiate()
		new_effect_generator.position = Global.touch_positions["B" + str(i+1)]
		new_effect_generator.note_position = "B" + str(i+1)
		$Circle/EffectGenerators.add_child(new_effect_generator)
		
	# C
	if true: # trolley
		var effect_generator = preload("res://note detail stuffs/effect_generator.tscn")
		var new_effect_generator = effect_generator.instantiate()
		new_effect_generator.position = Global.touch_positions["C1"]
		new_effect_generator.note_position = "C1"
		$Circle/EffectGenerators.add_child(new_effect_generator)
		
	for i in range(8): # D1-D8
		var effect_generator = preload("res://note detail stuffs/effect_generator.tscn")
		var new_effect_generator = effect_generator.instantiate()
		new_effect_generator.position = Global.touch_positions["D" + str(i+1)]
		new_effect_generator.note_position = "D" + str(i+1)
		$Circle/EffectGenerators.add_child(new_effect_generator)
		
	for i in range(8): # E1-E8
		var effect_generator = preload("res://note detail stuffs/effect_generator.tscn")
		var new_effect_generator = effect_generator.instantiate()
		new_effect_generator.position = Global.touch_positions["E" + str(i+1)]
		new_effect_generator.note_position = "E" + str(i+1)
		$Circle/EffectGenerators.add_child(new_effect_generator)
	
	for i in range(8):
		var effect_generator = preload("res://note detail stuffs/effect_generator.tscn")
		var new_effect_generator = effect_generator.instantiate()
		new_effect_generator.position = Global.touch_positions[str(i+1)]
		new_effect_generator.rotation = i * TAU / 8 + TAU / 16
		new_effect_generator.note_position = str(i+1)
		$Circle/EffectGenerators.add_child(new_effect_generator)

func effect_trigger(effect_name: String, note_position: String):
	var effect_generator: Node2D
	for node in $Circle/EffectGenerators.get_children():
		if node.get("note_position") == note_position:
			effect_generator = node
	if effect_generator:
		if effect_name == "tap_hit":
			effect_generator.tap_hit()
		elif effect_name == "hold_start":
			effect_generator.hold_start()
		elif effect_name == "hold_end":
			effect_generator.hold_end()
		elif effect_name == "touch_hit":
			effect_generator.touch_hit()
		elif effect_name == "firework":
			effect_generator.firework()
		elif effect_name == "break_hit":
			effect_generator.break_hit()
	else:
		print("Effect generator with position ", note_position, " not found.")
