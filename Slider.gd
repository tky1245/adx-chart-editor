extends Node2D
var beat: int
var bpm: float
var note_property_break: bool
var note_property_ex: bool
var note_property_touch: bool
var note_property_firework: bool # um
var note_property_both: bool
var note_position: String
var sliders: Array = []


func preview_render(current_time: float) -> void:
	pass
	
func initialize(pos: String = note_position) -> void:
	pass
	
func timeline_object_render() -> void:
	pass

func slider(target_pos: int, slider_shape: String, duration: Array, delay: Array) -> Dictionary:
	var new_dict: Dictionary = {}
	return new_dict
