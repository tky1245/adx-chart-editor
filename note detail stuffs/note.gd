class_name Note extends Node2D

enum type{
	TAP,
	TAP_HOLD,
	TOUCH,
	TOUCH_HOLD
}

var beat: int = 0
var bpm: float = 0.0
var note_property_break: bool = false
var note_property_ex: bool = false
var note_property_firework: bool = false
var note_property_both: bool = false
var note_property_star: bool = false
var note_property_mine: bool = false 
var note_star_spinning: bool = false
var note_position: String = ""
var sliders: Array = [] # Consists of dicts, storing properties of sliders
var slider_tapless: bool = false
var slider_both: bool = false
var delay_ticks: int = 0 # 128ths per tick

var selected: bool = false
signal effect_trigger



func preview_render(current_time: float = Global.current_time) -> void:
	note_render(current_time)
	slider_render(current_time)

func note_render(current_time: float = Global.current_time) -> void:
	pass

func slider_render(current_time: float = Global.current_time) -> void:
	for slider in $Sliders.get_children():
		slider.slider_render(current_time)

func timeline_object_render() -> void:
	if slider_tapless and sliders.size() > 0:
		$TimelineIndicator.visible = false
	else:
		var time = Global.timeline_beats[beat] + (delay_ticks / bpm / 128 * Global.beats_per_bar)
		if time > Global.timeline_visible_time_range["Start"] and time < Global.timeline_visible_time_range["End"]:
			$TimelineIndicator.visible = true
			$TimelineIndicator.position.x = Global.time_to_timeline_pos_x(time)
		else:
			$TimelineIndicator.visible = false
	for slider in $Sliders.get_children():
		slider.timeline_object_render()

func sfx_trigger(previous_time: float, current_time: float, offset: float = Global.sfx_offset) -> void: # tells program to play sfx
	pass

func initialize() -> void: # get note ready
	set_duration()
	set_note_position()
	note_draw()
	slider_draw()
	set_selected()

func note_draw() -> void: # draw the note
	pass

func slider_draw(both: bool = slider_both) -> void: # draw sliders of the note
	slider_both = both
	for node in $Sliders.get_children():
		node.free()
	for slider_args in sliders: # make sliders
		if sliders.size() > 1 or both:
			slider_args["slider_property_both"] = true
		else:
			slider_args["slider_property_both"] = false
		create_slider(slider_args)
	set_selected()

func timeline_object_draw() -> void:
	pass

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

func set_duration(arr: Array = [1.0, 4]) -> void:
	pass

func set_note_position(pos: String = note_position) -> void:
	pass

func set_selected(option: bool = selected) -> void:
	pass

func select_area() -> Array: # return clickable area 
	return []

func get_args() -> Dictionary:
	var new_dict: Dictionary = {
	"type": type,
	"beat": beat,
	"bpm": bpm,
	"note_property_break": note_property_break,
	"note_property_ex": note_property_ex,
	"note_property_firework": note_property_firework,
	"note_property_both": note_property_both,
	"note_property_star": note_property_star,
	"note_property_mine": note_property_mine,
	"note_position": note_position,
	"sliders": sliders,
	}
	return new_dict

func get_slider_count() -> int:
	return sliders.size()

func is_star() -> bool:
	return note_property_star
