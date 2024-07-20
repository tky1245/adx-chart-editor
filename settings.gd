extends Window

var settings_cache: Dictionary

func _on_close_requested():
	if settings_cache:
		Global.settings_set(settings_cache)
	visible = false

func settings_sync():
	$GridContainer/BGDim/BGDimField.text = str(Global.background_dim)
	$GridContainer/NoteSpeed/NoteSpeedField.text = str(Global.note_speed)
	$GridContainer/TouchSpeed/TouchSpeedField.text = str(Global.touch_speed)
	$GridContainer/SFXOffset/SFXOffsetField.text = str(Global.sfx_offset)
	$GridContainer/C1toC/C1toCCheckBox.button_pressed = bool(Global.remove_num_from_c_when_exporting)

func get_cache() -> Dictionary:
	var dict: Dictionary = {
		"background_dim": Global.background_dim,
		"remove_num_from_c_when_exporting": Global.remove_num_from_c_when_exporting,
		"note_speed": Global.note_speed,
		"touch_speed": Global.touch_speed,
		"sfx_offset": Global.sfx_offset
	}
	return dict

func _on_cancel_pressed():
	if settings_cache:
		Global.settings_set(settings_cache)
	visible = false

func _on_save_pressed():
	var dict: Dictionary = {
		"background_dim": float($GridContainer/BGDim/BGDimField.text),
		"remove_num_from_c_when_exporting": bool($GridContainer/C1toC/C1toCCheckBox.button_pressed),
		"note_speed": float($GridContainer/NoteSpeed/NoteSpeedField.text),
		"touch_speed": float($GridContainer/TouchSpeed/TouchSpeedField.text),
		"sfx_offset": float($GridContainer/SFXOffset/SFXOffsetField.text)
	}
	Global.settings_set(dict)
	Global.settings_save()
	settings_sync()
	visible = false

func _on_bg_dim_field_text_submitted(new_text):
	Global.background_dim = float(new_text)
	Global.bg_dim_changed.emit()
	settings_sync()

func _on_note_speed_field_text_submitted(new_text):
	Global.note_speed = float(new_text)
	settings_sync()

func _on_touch_speed_field_text_submitted(new_text):
	Global.touch_speed = float(new_text)
	settings_sync()

func _on_sfx_offset_field_text_submitted(new_text):
	Global.sfx_offset = float(new_text)
	settings_sync()

func _on_c_1_to_c_check_box_toggled(toggled_on):
	Global.remove_num_from_c_when_exporting = toggled_on
	settings_sync()
