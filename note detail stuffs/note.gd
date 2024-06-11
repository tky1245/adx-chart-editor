extends Node
enum type{
	TAP,
	TAP_HOLD,
	TOUCH,
	TOUCH_HOLD
}

func new_note(note_type: type, args: Dictionary) -> Node:
	var note
	if note_type == type.TAP:
		var tap = preload("res://note detail stuffs/tap.tscn")
		note = tap.instantiate()
	elif note_type == type.TOUCH:
		var touch = preload("res://note detail stuffs/touch.tscn")
		note = touch.instantiate()
	elif note_type == type.TAP_HOLD:
		var tap_hold = preload("res://note detail stuffs/tap_hold.tscn")
		note = tap_hold.instantiate()
	elif note_type == type.TOUCH_HOLD:
		var touch_hold = preload("res://note detail stuffs/touch_hold.tscn")
		note = touch_hold.instantiate()
	
	
	for key in args:
		note.set(key, args[key])

	return note

func slider(target_pos: int, slider_shape: String, duration: Array, delay: Array) -> Dictionary:
	var new_dict: Dictionary = {}
	return new_dict
