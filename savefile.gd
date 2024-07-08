extends Node
var img_extensions: Array = [".jpg", ".png", ".jpeg"]
func _ready():
	var dir_path = Global.CHART_STORAGE_PATH.left(len("Charts/"))
	var dir = DirAccess.open(dir_path)
	dir.make_dir("Charts")
	
func create_chart(chart_name: String, track_path: String):
	var chart_storage = DirAccess.open(Global.CHART_STORAGE_PATH)
	chart_storage.make_dir(chart_name)

	var track_format = "." + track_path.get_slice(".", track_path.count("."))
	chart_storage.copy(track_path, Global.CHART_STORAGE_PATH + chart_name + "/track" + track_format)
	Global.current_chart_name = chart_name
	Global.current_chart_data = new_chart_save(chart_name)
	save_chart()

func load_chart(chart_dir: String = Global.CHART_STORAGE_PATH + Global.current_chart_name + "/"):
	var file = FileAccess.open(chart_dir + "chart.mai", FileAccess.READ)
	var json_string = file.get_line()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			Global.current_chart_data = data_received
			print("Data fetched")
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

func save_chart(chart_dir: String = Global.CHART_STORAGE_PATH + Global.current_chart_name + "/", chart_data: Dictionary = Global.current_chart_data):
	var file = FileAccess.open(chart_dir + "chart.mai", FileAccess.WRITE)
	print("chart dir: ", str(chart_dir + "chart.mai"))
	var jstr = JSON.stringify(chart_data)
	file.store_line(jstr)
	file.close()
	print("line_stored")
	print(jstr)

func new_chart_save(title: String, artist: String = "") -> Dictionary:
	var new_dict: Dictionary = {
		"title" = title,
		"artist" = artist,
	}
	
	return new_dict

func maidata_to_chart(data: String) -> Dictionary:
	var chart_dict: Dictionary
	if data:
		const numbers = ["1", "2", "3", "4", "5", "6", "7", "8"]
		const decorators_2_digits = ["$$"]
		const decorators_1_digits = ["b", "x", "h", "f", "$", "?", "@"]
		const slider_shape_2_digits = ["pp", "qq"]
		const slider_shape_1_digits = ["-", "<", ">", "v", "w", "p", "q", "^", "V"]
		
		var remaining_string: String = data
		var bpm_changes: Array = []
		var bd_changes: Array = []
		var notes: Array = []
		var beat_counter: int = 0
		var line_count: int = 0
		for i in range(len(remaining_string)): # comment removal
			var comment_start_index = remaining_string.find("||")
			if comment_start_index == -1:
				break
			var comment_end_index = remaining_string.find("\n", comment_start_index)
			remaining_string = remaining_string.erase(comment_start_index, comment_end_index - comment_start_index)
		
		
		remaining_string.replace(" ", "") # space removal
		
		var string_splited_by_beat = remaining_string.split(",", true)
		for beat in string_splited_by_beat.size():
			var string_splited_by_tick = string_splited_by_beat[beat].split("`", true)
			var ongoing_bpm: float = 0.0 # used to calculate slider delay
			for delay_ticks in string_splited_by_tick.size():
				for note_string in string_splited_by_tick[delay_ticks].split("/", true):
					var current_bpm: float
					var current_beat_divisor: int
					
					var linebreaks = note_string.count("\n")
					note_string = note_string.replace("\n", "")
					
					while note_string.left(1) in ["(", "{"]:
						if note_string.begins_with("("): # bpm change
							var bracket_start_index = 0
							var bracket_end_index = note_string.find(")")
							current_bpm = float(note_string.left(bracket_end_index).right(-1))
							note_string = note_string.right(-(bracket_end_index+1))
						elif note_string.begins_with("{"): # beat divisor change
							var bracket_start_index = 0
							var bracket_end_index = note_string.find("}")
							current_beat_divisor = int(note_string.left(bracket_end_index).right(-1))
							note_string = note_string.right(-(bracket_end_index+1))
					
					if current_bpm:
						ongoing_bpm = current_bpm
						bpm_changes.append({
							"beat": beat,
							"bpm": current_bpm
						})
					if current_beat_divisor:
						bd_changes.append({
							"beat": beat,
							"bd": current_beat_divisor
						})
					
					var note_args: Dictionary
					note_args["beat"] = beat
					note_args["bpm"] = ongoing_bpm
					var force_unstar: bool = false
					
					if note_string.left(1) in numbers: # tap_position
						if len(note_string) == 2 and note_string.right(1) in numbers: # special case for boths
							for note_position in [note_string[0], note_string[1]]:
								notes.append({
									"beat": beat,
									"bpm": ongoing_bpm,
									"note_position": note_position,
									"type": Note.type.TAP,
								})
							break
						else:
							note_args["note_position"] = note_string.left(1)
							note_args["type"] = Note.type.TAP
							note_string = note_string.right(-1)
					elif note_string.left(2).right(1) in numbers: # touch_position
						note_args["note_position"] = note_string.left(2)
						note_args["type"] = Note.type.TOUCH
						note_string = note_string.right(-2)
					else: # no note here, probably
						break
						
					# search for decorators
					while len(note_string) > 0 and (note_string.left(2) in decorators_2_digits or note_string.left(1) in decorators_1_digits):
						if note_string.left(2) in decorators_2_digits:
							var decorator = note_string.left(2)
							if decorator == "$$":
								note_args["note_property_star"] = true
								note_args["note_star_spinning"] = true
							note_string = note_string.right(-2)
						if note_string.left(1) in decorators_1_digits:
							var decorator = note_string.left(1)
							if decorator == "b":
								note_args["note_property_break"] = true
							elif decorator == "x":
								note_args["note_property_ex"] = true
							elif decorator == "f":
								note_args["note_property_firework"] = true
							elif decorator == "h":
								if note_args["type"] == Note.type.TAP:
									note_args["type"] = Note.type.TAP_HOLD
								elif note_args["type"] == Note.type.TOUCH:
									note_args["type"] = Note.type.TOUCH_HOLD
							elif decorator == "$":
								note_args["note_property_star"] = true
							elif decorator == "?":
								note_args["slider_tapless"] = true
							elif decorator == "@":
								force_unstar = true
							note_string = note_string.right(-1)
					
					# search for hold duration
					if note_args.get("type") in [Note.type.TAP_HOLD, Note.type.TOUCH_HOLD]:
						if note_string.begins_with("["):
							var bracket_end_index = note_string.find("]")
							var duration_string = note_string.left(bracket_end_index).right(-1)
							note_string = note_string.right(-(bracket_end_index+1))
							if duration_string.begins_with("#"): # abs duration
								var abs_duration = float(duration_string.right(-1))
								note_args["duration_arr"] = [abs_duration, 0]
							else:
								var duration_x = float(duration_string.left(duration_string.find(":")))
								var duration_y = int(duration_string.right(-(duration_string.find(":")+1)))
								note_args["duration_arr"] = [duration_x, duration_y]
						else:
							note_args["duration_arr"] = [0.0, 1]
					
					
					# search for sliders
					if note_string.left(2) in slider_shape_2_digits or note_string.left(1) in slider_shape_1_digits: # has a slider
						var sliders: Array = []
						var slider_split = note_string.split("*")
						for slider_string in slider_split:
							var slider_args: Dictionary
							
							# construct slider shape
							slider_args["slider_shape_arr"] = []
							while slider_string.left(2) in slider_shape_2_digits or slider_string.left(1) in slider_shape_1_digits:
								var segment_shape: String
								if slider_string.left(2) in slider_shape_2_digits:
									segment_shape = slider_string.left(2)
									slider_string = slider_string.right(-2)
									
								elif slider_string.left(1) in slider_shape_1_digits:
									segment_shape = slider_string.left(1)
									slider_string = slider_string.right(-1)
								else:
									print("Invalid note decorator/slider shape notation, at line ", line_count)
									print('"', string_splited_by_tick[delay_ticks] ,'"')
									break
								
								
								var target_position: String
								if slider_string.left(1) in numbers: # tap
									target_position = slider_string.left(1)
									slider_string = slider_string.right(-1)
								elif slider_string.left(2).right(1) in numbers: # touch
									target_position = slider_string.left(2)
									slider_string = slider_string.right(-2)
								elif slider_string.left(1) == "C": # special case 
									target_position = "C1"
									slider_string = slider_string.right(-1)
								else:
									print("Slider shape position error, at line ", line_count)
									print('"', string_splited_by_tick[delay_ticks] ,'"')
									break
									
								slider_args["slider_shape_arr"].append([segment_shape, target_position])
							
							# handle slider duration
							if slider_string.begins_with("["):
								var bracket_start_index = 0
								var bracket_end_index = slider_string.find("]")
								var slider_duration_string = slider_string.left(bracket_end_index).right(-1)
								slider_string = slider_string.right(-(bracket_end_index+1))
								if slider_duration_string.contains("##"): # abs delay abs duration
									var arr = slider_duration_string.split("##")
									slider_args["delay_arr"] = [float(arr[0]), 0]
									slider_args["duration_arr"] = [float(arr[1]), 0]
								elif slider_duration_string.contains("#") and slider_duration_string.contains(":"): # custom bpm, beat divisor duration
									var custom_bpm = float(slider_duration_string.split("#")[0])
									var duration_x = float(slider_duration_string.split("#")[1].split(":")[0])
									var duration_y = int(slider_duration_string.split("#")[1].split(":")[1])
									var bpm_ratio = float_to_fraction(ongoing_bpm/custom_bpm)
									slider_args["delay_arr"] = [float(bpm_ratio[0]), int(4 * bpm_ratio[1])]
									slider_args["duration_arr"] = [duration_x, duration_y]
								elif slider_duration_string.contains("#") and not slider_duration_string.contains(":"): # custom bpm abs duration
									var custom_bpm = float(slider_duration_string.split("#")[0])
									var abs_duration = float(slider_duration_string.split("#")[1])
									var bpm_ratio = float_to_fraction(ongoing_bpm/custom_bpm)
									slider_args["delay_arr"] = [float(bpm_ratio[0]), int(4 * bpm_ratio[1])]
									slider_args["duration_arr"] = [abs_duration, 0]
								elif not slider_duration_string.contains("#") and slider_duration_string.contains(":"): # default
									var duration_x = float(slider_duration_string.split(":")[0])
									var duration_y = int(slider_duration_string.split(":")[1])
									slider_args["delay_arr"] = [1.0, 4]
									slider_args["duration_arr"] = [duration_x, duration_y]
								else:
									print("Slider duration not found, at line ", line_count)
									print('"', string_splited_by_tick[delay_ticks] ,'"')
									break
							
							# handle slider decorator
							while len(slider_string) > 0:
								if slider_string.left(1) == "b":
									slider_args["slider_property_break"] = true
									slider_string = slider_string.right(-1)
								else:
									print("Invalid slider decorator, at line ", line_count)
									print('"', string_splited_by_tick[delay_ticks] ,'"')
									break
							
							sliders.append(slider_args)
						note_args["sliders"] = sliders
						if force_unstar:
							note_args["note_property_star"] = false
						else:
							note_args["note_property_star"] = true
					
					if note_args.get("note_position"):
						notes.append(note_args)
					line_count += linebreaks
		chart_dict["bpm_changes"] = bpm_changes
		chart_dict["bd_changes"] = bd_changes
		chart_dict["notes"] = notes
	return chart_dict

func chart_to_maidata(data: Dictionary) -> String:
	var chart_string: String
	if data:
		var bpm_changes = data.get("bpm_changes")
		var bd_changes = data.get("bd_changes")
		var notes = data.get("notes")
		
		bpm_changes = arrange_by_arg(bpm_changes, "beat")
		bd_changes = arrange_by_arg(bd_changes, "beat")
		notes = arrange_by_arg(notes, "delay_ticks")
		notes = arrange_by_arg(notes, "beat")
		
		var beat_counter: int = 0
		var bar_counter: float = 0.0 # handles row spacing
		var ongoing_beat_divisor: int
		var delay_ticks_at_current_beat: int = 0
		var first_note_at_current_beat: bool = true
		while notes.size() > 0:
			var current_bpm: float
			for i in range(bpm_changes.size()):
				if bpm_changes.front().get("beat") == beat_counter:
					current_bpm = bpm_changes.pop_front().get("bpm")
				elif bpm_changes.front().get("beat") > beat_counter:
					break
			if current_bpm:
				chart_string += "(" + str(current_bpm) + ")"
				bar_counter = 0
			
			var current_beat_divisor: int
			for i in range(bd_changes.size()):
				if bd_changes.front().get("beat") == beat_counter:
					current_beat_divisor = bd_changes.pop_front().get("bd")
				elif bd_changes.front().get("beat") > beat_counter:
					break
			if current_beat_divisor:
				chart_string += "{" + str(current_beat_divisor) + "}"
				ongoing_beat_divisor = current_beat_divisor
			bar_counter += 1.0 / ongoing_beat_divisor
			
			for i in range(notes.size()): 
				if notes.front().get("beat") == beat_counter:
					var note = notes.pop_front()
					var note_string: String
					var tick_count = note.get("delay_ticks") if note.get("delay_ticks") else 0
					if tick_count > delay_ticks_at_current_beat:
						for j in range(note.get("delay_ticks") - delay_ticks_at_current_beat):
							chart_string += "`"
						delay_ticks_at_current_beat = note.get("delay_ticks")
					elif !first_note_at_current_beat:
						chart_string += "/"
						
					note_string += str(note.get("note_position"))
					
					# tap decorators
					if note.get("note_property_break"):
						note_string += "b"
					if note.get("note_property_ex"):
						note_string += "x"
					if note.get("note_property_firework"):
						note_string += "f"
					if note.get("note_property_star") and note.get("note_star_spinning") and (!note.get("sliders") or note.sliders.size() == 0):
						note_string += "$$"
					elif note.get("note_property_star") and !note.get("note_star_spinning") and (!note.get("sliders") or note.sliders.size() == 0):
						note_string += "$"
					elif !note.get("note_property_star") and (note.get("sliders") and note.get("sliders").size() > 0):
						note_string += "@"
					elif note.get("slider_tapless") and (note.get("sliders") and note.sliders.size() > 0):
						note_string += "?"
					
					# hold handling
					if note.get("type") and note.get("type") in [Note.type.TAP_HOLD, Note.type.TOUCH_HOLD]:
						if note.get("duration_arr")[1] == 0: # uses [0] as absolute time
							note_string += "h[#" + str(note.get("duration_arr")[0]) + "]"
						else:
							note_string += "h[" + str(note.get("duration_arr")[0]) + ":" + str(note.get("duration_arr")[1]) + "]"
					
					# slider handling
					if note.get("sliders") and note.get("sliders").size() > 0:
						var first_slider: bool = true
						for slider in note.get("sliders"):
							if !first_slider:
								note_string += "*"
							# slider shape
							for pair in slider.get("slider_shape_arr"):
								note_string += str(pair[0])
								note_string += str(pair[1])
							
							# slider decorator
							if slider.get("slider_property_break"):
								note_string += "b"
							# duration bracket
							if slider.get("delay_arr") == [1.0, 4] and slider.get("duration_arr")[1] != 0: # default
								note_string += "[" + str(slider.get("duration_arr")[0]) + ":" + str(slider.get("duration_arr")[1]) + "]"
							elif slider.get("delay_arr") != [1.0, 4] and slider.get("duration_arr")[1] != 0: # fake bpm change
								note_string += "[" + str(note.get("bpm") / (slider.get("delay_arr")[0] / slider.get("delay_arr")[1]) / 0.25) + "#" + str(slider.get("duration_arr")[0]) + ":" + str(slider.get("duration_arr")[1]) + "]"
							elif slider.get("delay_arr")[1] != 0 and slider.get("duration_arr")[1] == 0: # custom bpm + abs duration
								note_string += "["+ str(note.get("bpm") / (slider.get("delay_arr")[0] / slider.get("delay_arr")[1]) / 0.25) + "#" + str(slider.get("duration_arr")[0]) + "]"
							elif slider.get("delay_arr")[1] == 0 and slider.get("duration_arr")[1] == 0: # abs delay abs duration
								note_string += "[" + str(slider.get("delay_arr")[0]) + "##" + str(slider.get("duration_arr")[0]) + "]"
							elif slider.get("delay_arr")[1] == 0 and slider.get("duration_arr")[1] != 0: # abs delay, beat divisor duration; not supported in simai
								var abs_duration = slider.get("duration_arr")[0] / slider.get("duration_arr")[1] * 60 / note.bpm
								note_string += "[" + str(slider.get("delay_arr")[0]) + "##" + str(abs_duration) + "]"
							
							first_slider = false 
					chart_string += note_string
					first_note_at_current_beat = false
				elif notes.front().get("beat") > beat_counter:
					break
			
			chart_string += ","
			beat_counter += 1
			first_note_at_current_beat = true
			if bar_counter >= 0.9999999: # i hate rounding
				bar_counter -= int(bar_counter)
				chart_string += "\n"
	return chart_string
		
func arrange_by_arg(arr: Array, arg: String): # Bubble sort
	var temp_arr: Array = arr
	var swapped = false
	for i in range(len(temp_arr)):
		swapped = false
		for j in range(len(temp_arr) - 1):
			if temp_arr[j].get(arg) and (temp_arr[j].get(arg) > temp_arr[j + 1].get(arg)):
				var temp = temp_arr[j] # dumb swapping
				temp_arr[j] = temp_arr[j + 1]
				temp_arr[j + 1] = temp
				swapped = true
		if swapped == false:
			break
	return temp_arr

func float_to_fraction(value: float, max_denominator: int = 1000):
	var x = value
	var a = int(x)
	var numerator1 = a
	var numerator2 = 1
	var denominator1 = 1
	var denominator2 = 0
	var fraction = float(numerator1) / denominator1
	
	while abs(fraction - value) > 0.000001 and denominator1 < max_denominator:
		x = 1 / (x - a)
		a = int(x)
		var temp_numerator1 = numerator1
		numerator1 = a * numerator1 + numerator2
		numerator2 = temp_numerator1
		var temp_denominator1 = denominator1
		denominator1 = a * denominator1 + denominator2
		denominator2 = temp_denominator1
		fraction = float(numerator1) / denominator1

	return [numerator1, denominator1]
