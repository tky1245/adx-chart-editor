extends Node
enum type{
	TAP,
	TAP_HOLD,
	TOUCH,
	TOUCH_HOLD
}
var slider_shape_length: Dictionary

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

func sort_note_by_index(note_arr: Array[Node2D]) -> Array[Node2D]:
	var temp_arr = note_arr
	var swapped = false
	for i in range(len(temp_arr)):
		swapped = false
		for j in range(len(temp_arr) - 1):
			if temp_arr[j].get_index() > temp_arr[j + 1].get_index():
				var temp = temp_arr[j] # dumb swapping
				temp_arr[j] = temp_arr[j + 1]
				temp_arr[j + 1] = temp
				swapped = true
		if swapped == false:
			break
	return temp_arr
