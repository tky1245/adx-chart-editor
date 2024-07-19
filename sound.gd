extends Node
signal sfx_start
signal sfx_end
signal all_sfx_stop

# audio streams
# borrowed from majdata
const answer_sfx = preload("res://SFX/answer.wav") # idk what this is for
const break_sfx = preload("res://SFX/break.wav")
const break_slide_sfx = preload("res://SFX/break_slide.wav")
const break_slide_start_sfx = preload("res://SFX/break_slide_start.wav")
const hanabi_sfx = preload("res://SFX/hanabi.wav")
const judge_sfx = preload("res://SFX/judge.wav")
const judge_break_sfx = preload("res://SFX/judge_break_slide.wav")
const judge_break_slide_sfx = preload("res://SFX/judge_break_slide.wav")
const judge_ex_sfx = preload("res://SFX/judge_ex.wav")
const slide_sfx = preload("res://SFX/slide.wav")
const touch_sfx = preload("res://SFX/touch.wav")
const touch_hold_sfx = preload("res://SFX/touchHold_riser.wav")

# volume settings
var BGM_volume: float = 1
var answer_volume: float = 1
var judge_volume: float = 1
var slide_volume: float = 1
var break_volume: float = 1
var break_slide_volume: float = 1
var ex_volume: float = 1
var touch_volume: float = 1
var hanabi_volume: float = 1


func volume_load():
	var file = FileAccess.open("user://volume_mixer.json", FileAccess.READ)
	var json_string = file.get_line()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			BGM_volume = data_received.get("BGM_volume")
			answer_volume = data_received.get("answer_volume")
			judge_volume = data_received.get("judge_volume")
			slide_volume = data_received.get("slide_volume")
			break_volume = data_received.get("break_volume")
			break_slide_volume = data_received.get("break_slide_volume")
			ex_volume = data_received.get("ex_volume")
			touch_volume = data_received.get("touch_volume")
			hanabi_volume = data_received.get("hanabi_volume")

func volume_save():
	var dict: Dictionary = {
		"BGM_volume": BGM_volume,
		"answer_volume": answer_volume,
		"judge_volume": judge_volume,
		"slide_volume": slide_volume,
		"break_volume": break_volume,
		"break_slide_volume": break_slide_volume,
		"ex_volume": ex_volume,
		"touch_volume": touch_volume,
		"hanabi_volume": hanabi_volume,
	}
	var json = JSON.stringify(dict)
	var file = FileAccess.open("user://volume_mixer.json", FileAccess.WRITE)
	file.store_line(json)
	file.close()
	print("Volume saved")
	
