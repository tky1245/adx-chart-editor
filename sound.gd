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
