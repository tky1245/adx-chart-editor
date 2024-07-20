extends Window

var volume_cache: Dictionary


func volume_sync():
	# giant green block here
	$VBoxContainer/HBoxContainer/BGMSlider.value = int(100 * Sound.BGM_volume)
	$VBoxContainer/HBoxContainer/BGMTest.text = str(int(100 * Sound.BGM_volume), "%")
	$VBoxContainer/HBoxContainer2/AnswerSlider.value = int(100 * Sound.answer_volume)
	$VBoxContainer/HBoxContainer2/AnswerTest.text = str(int(100 * Sound.answer_volume), "%")
	$VBoxContainer/HBoxContainer3/JudgeSlider.value = int(100 * Sound.judge_volume)
	$VBoxContainer/HBoxContainer3/JudgeTest.text = str(int(100 * Sound.judge_volume), "%")
	$VBoxContainer/HBoxContainer4/SlideSlider.value = int(100 * Sound.slide_volume)
	$VBoxContainer/HBoxContainer4/SlideTest.text = str(int(100 * Sound.slide_volume), "%")
	$VBoxContainer/HBoxContainer5/BreakSlider.value = int(100 * Sound.break_volume)
	$VBoxContainer/HBoxContainer5/BreakTest.text = str(int(100 * Sound.break_volume), "%")
	$VBoxContainer/HBoxContainer6/BreakSlideSlider.value = int(100 * Sound.break_slide_volume)
	$VBoxContainer/HBoxContainer6/BreakSlideTest.text = str(int(100* Sound.break_slide_volume), "%")
	$VBoxContainer/HBoxContainer7/EXSlider.value = int(100 * Sound.ex_volume)
	$VBoxContainer/HBoxContainer7/EXTest.text = str(int(100 * Sound.ex_volume), "%")
	$VBoxContainer/HBoxContainer8/TouchSlider.value = int(100 * Sound.touch_volume)
	$VBoxContainer/HBoxContainer8/TouchTest.text = str(int(100 * Sound.touch_volume), "%")
	$VBoxContainer/HBoxContainer9/HanabiSlider.value = int(100 * Sound.hanabi_volume)
	$VBoxContainer/HBoxContainer9/HanabiTest.text = str(int(100 * Sound.hanabi_volume), "%")

func get_cache() -> Dictionary:
	var dict: Dictionary = {
		"BGM_volume": Sound.BGM_volume,
		"answer_volume": Sound.answer_volume,
		"judge_volume": Sound.judge_volume,
		"slide_volume": Sound.slide_volume,
		"break_volume": Sound.break_volume,
		"break_slide_volume": Sound.break_slide_volume,
		"ex_volume": Sound.ex_volume,
		"touch_volume": Sound.touch_volume,
		"hanabi_volume": Sound.hanabi_volume,
	}
	return dict

func _on_close_requested():
	if volume_cache:
		Sound.volume_set(get_cache())
	visible = false

func _on_save_pressed():
	Sound.volume_save()
	visible = false

func _on_cancel_pressed():
	if volume_cache:
		Sound.volume_set(get_cache())
	visible = false


func _on_bgm_slider_value_changed(value):
	Sound.BGM_volume = value / 100.0
	volume_sync()

func _on_answer_slider_value_changed(value):
	Sound.answer_volume = value / 100.0
	volume_sync()

func _on_judge_slider_value_changed(value):
	Sound.judge_volume = value / 100.0
	volume_sync()

func _on_slide_slider_value_changed(value):
	Sound.slide_volume = value / 100.0
	volume_sync()

func _on_break_slider_value_changed(value):
	Sound.break_volume = value / 100.0
	volume_sync()

func _on_break_slide_slider_value_changed(value):
	Sound.break_slide_volume = value / 100.0
	volume_sync()

func _on_ex_slider_value_changed(value):
	Sound.ex_volume = value / 100.0
	volume_sync()

func _on_touch_slider_value_changed(value):
	Sound.touch_volume = value / 100.0
	volume_sync()

func _on_hanabi_slider_value_changed(value):
	Sound.hanabi_volume = value / 100.0
	volume_sync()


func _on_bgm_test_pressed():
	pass
