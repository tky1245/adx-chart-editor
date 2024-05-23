extends Node2D
var previous_mouse_position: Vector2
var beats_per_bar = 4

# Placement Tools
var placement_selected: String = "None"
var toggle_multiplacing: bool = false
var toggle_break: bool = false
var toggle_ex: bool = false
var toggle_touch: bool = false

# Track Player
var song_length: float
var current_time: float

# Playback
var bar_dragging: bool = false
var mouse_holding_bar:bool = false
var previous_song_time: float

# Timeline

var timeline_bar_time:Array = []
var note_objects: Array = [] # {"Beat": int, "Node": Node} # to be removed
var timeline_dragging: bool = false

# note edit


func _ready():
	var file = FileAccess.open(Global.CURRENT_CHART_PATH, FileAccess.WRITE_READ) # Save file location
	load_external_song(Global.CURRENT_SONG_PATH)
	song_length = $AudioPlayers/TrackPlayer.stream.get_length() #um
	$PlaybackControls/TimeSlider/ProgressBar.max_value = song_length
	get_node("FileOptions/MenuButton").get_popup().connect("index_pressed", _on_option_pressed)


	
	# Draw a circle
	var density = 180
	for k in range(density):
		var dotx = Global.preview_radius * sin(2 * PI * k / density) + Global.preview_center.x
		var doty = Global.preview_radius * cos(2 * PI * k / density) + Global.preview_center.y
		$ChartPreview/Circle.add_point(Vector2(dotx, doty))
	# Draw polygons
	for region in $ChartPreview/TouchArea.get_children():
		if region.is_in_group("touchpos_A") or region.is_in_group("touchpos_B") or region.is_in_group("touchpos_E"):
			var newPolygon = Polygon2D.new()
			newPolygon.name = "PolygonFill"
			newPolygon.polygon = region.find_child("CollisionPolygon2D").polygon
			newPolygon.color = Color(1, 1, 1, 0.5)
			region.add_child(newPolygon)
			var newLine = Line2D.new()
			newLine.points = region.find_child("CollisionPolygon2D").polygon
			newLine.width = 2
			newLine.closed = true
			region.add_child(newLine)
	timeline_object_update()
	timeline_render("all")
	# test
	for pos_name in Global.touch_positions:
		var lbl = Label.new()
		lbl.text = "o"
		lbl.position = Global.touch_positions[pos_name] - Vector2(lbl.get_theme_default_font_size()/2, lbl.get_theme_default_font_size()/2)
		add_child(lbl)
	

func _input(event): # man that precoded slider sucks
	if bar_dragging:
		if event is InputEventMouse:
			if event.position.x < $PlaybackControls/TimeSlider/ProgressBar.position.x:
				current_time = 0
			elif event.position.x > $PlaybackControls/TimeSlider/ProgressBar.position.x + $PlaybackControls/TimeSlider/ProgressBar.size.x:
				current_time = song_length
			else:
				current_time = song_length * (event.position.x - $PlaybackControls/TimeSlider/ProgressBar.position.x)/$PlaybackControls/TimeSlider/ProgressBar.size.x
		#TODO: Rerender everything 
		timeline_render("all")
	if event is InputEventMouseButton and !event.pressed:
		bar_dragging = false
	
	if timeline_dragging:
		if event is InputEventMouseMotion:
			var position_delta = event.position - previous_mouse_position if previous_mouse_position != Vector2(-1, -1) else Vector2(0, 0)
			var time_delta = position_delta.x / Global.timeline_pixels_to_second / Global.timeline_zoom
			previous_mouse_position = event.position
			if current_time - time_delta < 0:
				current_time = 0
			elif current_time - time_delta > song_length:
				current_time = song_length
			else:
				current_time = current_time - time_delta
			#TODO: render
		timeline_render("all")
		if event is InputEventMouseButton and !event.pressed:
			timeline_dragging = false
		
func _process(_delta):
	if !$Timeline/SongTimer.is_stopped():
		current_time = song_length - $Timeline/SongTimer.time_left
	$PlaybackControls/TimeSlider/ProgressBar.value = current_time
	$PlaybackControls/ElapsedTime.text = time_format(current_time)
	timeline_render("all")


func _on_option_pressed(index):
	if index == 0: #Save
		pass
	if index == 1: #Export to maidata
		pass
	if index == 2: #Return to menu
		get_tree().change_scene_to_file("res://main_menu.tscn")




# Placement Tool Toggles
func _on_tap_toggle_pressed():
	if placement_selected == "Tap":
		if toggle_multiplacing == false:
			toggle_multiplacing = true
		else:
			placement_selected = "None"
	else:
		placement_selected = "Tap"
		toggle_multiplacing = false
	placement_tools_highlight_update()

func _on_hold_toggle_pressed():
	if placement_selected == "Hold":
		if toggle_multiplacing == false:
			toggle_multiplacing = true
		else:
			placement_selected = "None"
	else:
		placement_selected = "Hold"
		toggle_multiplacing = false
	placement_tools_highlight_update()

func _on_slider_toggle_pressed():
	if placement_selected == "Slider":
		if toggle_multiplacing == false:
			toggle_multiplacing = true
		else:
			placement_selected = "None"
	else:
		placement_selected = "Slider"
		toggle_multiplacing = false
	placement_tools_highlight_update()

func placement_tools_highlight_update():
	$PlacementTools/Tap/Highlight.visible = true if placement_selected == "Tap" else false
	$PlacementTools/Hold/Highlight.visible = true if placement_selected == "Hold" else false
	$PlacementTools/Slider/Highlight.visible = true if placement_selected == "Slider" else false
	if toggle_multiplacing == false:
		$PlacementTools/Tap/Highlight.play("white")
		$PlacementTools/Hold/Highlight.play("white")
		$PlacementTools/Slider/Highlight.play("white")
	else:
		$PlacementTools/Tap/Highlight.play("yellow")
		$PlacementTools/Hold/Highlight.play("yellow")
		$PlacementTools/Slider/Highlight.play("yellow")

func _on_break_toggle_toggled(toggled_on):
	toggle_break = toggled_on

func _on_ex_toggle_toggled(toggled_on):
	toggle_ex = toggled_on

func _on_touch_toggle_toggled(toggled_on):
	toggle_ex = toggled_on

# Song Player
func _on_play_pause_pressed(): # Play/Pause Button
	if $Timeline/SongTimer.is_stopped():
		if current_time != song_length:
			$PlaybackControls/PlayPause.text = "❚❚"
			$Timeline/SongTimer.start(song_length - current_time)
			$AudioPlayers/TrackPlayer.play(current_time)
	else:
		$PlaybackControls/PlayPause.text = "▶"
		current_time = song_length - $Timeline/SongTimer.time_left # Move time cursor to where it stopped
		$Timeline/SongTimer.stop()
		$AudioPlayers/TrackPlayer.stop()

func _on_stop_pressed():# Stop Button
	if !$Timeline/SongTimer.is_stopped():
		$PlaybackControls/PlayPause.text = "▶"
		$Timeline/SongTimer.stop()
		$AudioPlayers/TrackPlayer.stop()

func _on_song_timer_timeout(): # Song Ended
	$PlaybackControls/PlayPause.text = "▶"
	$AudioPlayers/TrackPlayer.stop()

func time_format(time_num: float): # Seconds to Time String
	var remaining_time: float = time_num
	var time_dict: Dictionary = {"H": 0, "M": 0, "S": 0, "MS": 0}
	while remaining_time >= 3600: # Hours, but why
		remaining_time -= 3600
		time_dict["H"] += 1
	while remaining_time >= 60:
		remaining_time -= 60
		time_dict["M"] += 1
	while remaining_time >= 1:
		remaining_time -= 1
		time_dict["S"] += 1
	time_dict["MS"] = int(100 * remaining_time)
	
	var time_string: String = ""
	# Brute Forcing it
	if time_dict["H"] > 0:
		time_string += time_dict["H"] + ":"
	if time_dict["M"] == 0 and time_dict["H"] > 0:
		time_string += "00:"
	elif time_dict["M"] == 0:
		time_string += "0:"
	elif time_dict["M"] < 10:
		time_string += "0" + str(time_dict["M"]) + ":"
	else:
		time_string += str(time_dict["M"]) + ":"
	if time_dict["S"] < 10:
		time_string += "0" + str(time_dict["S"]) + "."
	else:
		time_string += str(time_dict["S"]) + "."
	if time_dict["MS"] < 10:
		time_string += "0" + str(time_dict["MS"])
	else:
		time_string += str(time_dict["MS"])
	
	return str(time_string)

func load_external_song(path): # Load a song
	var file = FileAccess.open(path, FileAccess.READ)
	if path.ends_with("track.mp3"):
		var mp3 = AudioStreamMP3.new()
		mp3.data = file.get_buffer(file.get_length())
		$AudioPlayers/TrackPlayer.stream = mp3
	elif path.ends_with("track.ogg"):
		var ogg = AudioStreamOggVorbis.load_from_buffer(file.get_buffer(file.get_length()))
		$AudioPlayers/TrackPlayer.stream = ogg
	else:
		print("song not loaded")

# Bar and Timeline

func _on_progress_bar_gui_input(event): # Song Progress Bar Dragged
	if event is InputEventMouseButton and event.pressed:
		bar_dragging = true
		$PlaybackControls/PlayPause.text = "▶" # Stop the song from continue playing
		$Timeline/SongTimer.stop()
		$AudioPlayers/TrackPlayer.stop()

func _on_note_timeline_gui_input(event): # Timeline Dragged
	if event is InputEventMouseButton and event.pressed:
		timeline_dragging = true
		$PlaybackControls/PlayPause.text = "▶" # Stop the song from continue playing
		$Timeline/SongTimer.stop()
		$AudioPlayers/TrackPlayer.stop()
		previous_mouse_position = Vector2(-1, -1)

func timeline_visible_range_update(): # Update timeline, use before render
	var leftmost_time: float = current_time + float(Global.timeline_leftmost_x - Global.timeline_pointer_x) / Global.timeline_pixels_to_second / Global.timeline_zoom
	var rightmost_time: float = current_time + float(Global.timeline_rightmost_x - Global.timeline_pointer_x) / Global.timeline_pixels_to_second / Global.timeline_zoom
	Global.timeline_visible_time_range["Start"] = leftmost_time
	Global.timeline_visible_time_range["End"] = rightmost_time

# Use when editing notes
func timeline_object_update():
	#TODO: put note reader in
	var bpm_array: Array = [] # ["Beat": int, "Value": float]
	var bd_array: Array = [] # ["Beat": int, "Value": int]
	if $BPMChanges.get_child_count() == 0: # No BPM?
		bpm_array.append({"Beat": 0, "Value": 160.0})
	else:
		for bpm_node in $BPMChanges.get_children(): # read them all
			bpm_array.append({"Beat": bpm_node.beat, "Value": bpm_node.bpm})
	if $BeatDivisorChanges.get_child_count() == 0: # same for bd node
		bd_array.append({"Beat": 0, "Value": 4})
	else:
		for bd_node in $BeatDivisorChanges.get_children():
			bd_array.append({"Beat": bd_node.beat, "Value": bd_node.beat_divisor})
	
	# Ensure BPMDivisorArray is sorted by Beat
	bpm_array = arrange_by_beat(bpm_array)
	bd_array = arrange_by_beat(bd_array)
	print("bpm_array: ", bpm_array)
	print("bd_array: ", bd_array)
	
	# Reading bpm/bd and generate new beat arrays
	Global.timeline_beats.clear()
	var temp_time: float = 0
	var temp_bpm: float = bpm_array[0]["Value"] if bpm_array.size() > 0 else 160
	var temp_beat_divisor: float = bd_array[0]["Value"] if bd_array.size() > 0 else 4
	var temp_beat: int = 0 # Beat counter
	
	while temp_time < song_length: # only do calculation within song length
		for item in bpm_array: # Read BPM change and check if there's one on current beat
			if item["Beat"] == temp_beat:
				temp_bpm = item["Value"]
				break # no need to continue looping
		for item in bd_array:
			if item["Beat"] == temp_beat:
				temp_beat_divisor = item["Value"]
				break

		Global.timeline_beats.append(temp_time)
		temp_time += (60.0 / temp_bpm) / temp_beat_divisor * beats_per_bar # time calculation
		temp_beat += 1
		
	# print("Global.timeline_beats: ", Global.timeline_beats)    -too long tbh
	print("Global.timeline_beats size: ", Global.timeline_beats.size())
	
	# bar array starts here
	
	timeline_bar_time.clear()
	temp_time = 0 # reuse some variables
	temp_bpm = 160
	var temp_idx = 0
	var bpm_read = false
	
	if bpm_array.size() > 0:
		temp_bpm = bpm_array[0]["Value"]
	
	while temp_time < song_length:
		bpm_read = false # so that it reads bpm only 1 time
		while temp_idx < bpm_array.size() and not bpm_read:
			var item = bpm_array[temp_idx]
			if temp_time >= Global.timeline_beats[item["Beat"]]:
				temp_time = Global.timeline_beats[item["Beat"]]
				temp_bpm = item["Value"]
				temp_idx += 1
				bpm_read = true
			else:
				break
		
		timeline_bar_time.append(temp_time)
		temp_time += 60.0 / temp_bpm * beats_per_bar


	timeline_render("bar")
	timeline_render("beat")


func arrange_by_beat(arr): # Bubble sort
	var temp_arr: Array = arr
	var swapped = false
	for i in range(len(temp_arr)):
		swapped = false
		for j in range(len(temp_arr) - 1):
			if temp_arr[j]["Beat"] > temp_arr[j + 1]["Beat"]:
				var temp = temp_arr[j]["Beat"] # dumb swapping
				temp_arr[j]["Beat"] = temp_arr[j + 1]["Beat"]
				temp_arr[j + 1]["Beat"] = temp
				swapped = true
		if swapped == false:
			break
	return temp_arr

func timeline_render(type: String): # Render objects on timeline
	if type == "bar":
		for line in $TimelineBars.get_children():
			line.queue_free()
		for time in timeline_bar_time:
			if time > Global.timeline_visible_time_range["Start"] and time < Global.timeline_visible_time_range["End"]:
				var newLine = Line2D.new()
				newLine.default_color = Color.DARK_GREEN
				newLine.width = 2
				newLine.add_point(Vector2(Global.time_to_timeline_pos_x(time), 516))
				newLine.add_point(Vector2(Global.time_to_timeline_pos_x(time), 648))
				$TimelineBars.add_child(newLine)
	elif type == "beat":
		for line in $TimelineBeats.get_children():
			line.queue_free()
		for time in Global.timeline_beats:
			if time > Global.timeline_visible_time_range["Start"] and time < Global.timeline_visible_time_range["End"]:
				var newLine = Line2D.new()
				newLine.default_color = Color.WEB_GRAY
				newLine.width = 2
				newLine.add_point(Vector2(Global.time_to_timeline_pos_x(time), 516))
				newLine.add_point(Vector2(Global.time_to_timeline_pos_x(time), 648))
				$TimelineBeats.add_child(newLine)
	elif type == "bpm_change":
		for bpm_node in $BPMChanges.get_children():
			bpm_node.render()
	elif type == "bd_change":
		for bd_node in $BeatDivisorChanges.get_children():
			bd_node.render()
	elif type == "all": # Default, render everything 
		timeline_visible_range_update()
		timeline_render("bar")
		timeline_render("beat")
		timeline_render("bpm_change")
		timeline_render("bd_change")

func time_to_beat(time: float) -> int:
	if Global.timeline_beats.size() == 0:
		return 0
		
	if time <= Global.timeline_beats[0]:
		return Global.timeline_beats[0]

	for i in range(Global.timeline_beats.size()):
		var beat_time = Global.timeline_beats[i]

		if time < beat_time:
			if i == 0:
				return beat_time # If it's before the first beat
			else:
				var prev_beat_time = Global.timeline_beats[i - 1]
				# Return the closer beat
				if (time - prev_beat_time) < (beat_time - time):
					return i - 1
				else:
					return i

	return Global.timeline_beats.back()


# Handles BPM/BD change window/button
func _on_add_bpm_node_pressed():
	if	!$TimeLineControls/BPMWindow.visible:
		add_bpm_window_show()
		Global.beat_change_cursor = null
	else:
		$TimeLineControls/BPMWindow.visible = false

func add_bpm_window_show():
	$TimeLineControls/BPMWindow.visible = true
	$TimeLineControls/BeatDivisorWindow.visible = false

func _on_add_divisor_node_pressed():
	if	!$TimeLineControls/BeatDivisorWindow.visible:
		add_bd_window_show()
		Global.beat_change_cursor = null
	else:
		$TimeLineControls/BeatDivisorWindow.visible = false

func add_bd_window_show():
	$TimeLineControls/BeatDivisorWindow.visible = true
	$TimeLineControls/BPMWindow.visible = false

func _on_beat_divisor_field_text_submitted(new_text):
	var beat_divisor = float(new_text)
	if beat_divisor > 0:
		var beat = time_to_beat(current_time) if $BeatDivisorChanges.get_child_count() > 0 else 0
		if !Global.beat_change_cursor:
			for bd_node in $BeatDivisorChanges.get_children():
				if beat == bd_node.beat:
					Global.beat_change_cursor = bd_node
			var beat_divisor_node = preload("res://note detail stuffs/beat_divisor_node.tscn")
			var new_node = beat_divisor_node.instantiate()
			new_node.beat_divisor = beat_divisor
			new_node.beat = beat
			new_node.connect("bd_button_clicked", _on_bd_node_clicked, 8)
			$BeatDivisorChanges.add_child(new_node)
		else:
			var node = Global.beat_change_cursor
			node.beat_divisor = beat_divisor
			node.button_update()
		timeline_object_update()
		timeline_render("all")
	$TimeLineControls/BeatDivisorWindow.visible = false
	$TimeLineControls/BeatDivisorWindow/BeatDivisorField.text = ""

func _on_bpm_field_text_submitted(new_text):
	var bpm = int(new_text)
	if bpm > 0:
		var beat = time_to_beat(current_time) if $BPMChanges.get_child_count() > 0 else 0
		if !Global.beat_change_cursor:
			for bpm_node in $BPMChanges.get_children(): # Check for overlaps
				if beat == bpm_node.beat:
					Global.beat_change_cursor = bpm_node
			var bpm_node = preload("res://note detail stuffs/bpm_node.tscn")
			var new_node = bpm_node.instantiate()
			new_node.bpm = bpm
			new_node.beat = beat
			print(current_time)
			print(new_node.beat)
			new_node.connect("bpm_button_clicked", _on_bpm_node_clicked, 8)
			$BPMChanges.add_child(new_node)
		else:
			var node = Global.beat_change_cursor
			node.bpm = bpm
			node.button_update()
		timeline_object_update()
		timeline_render("all")
	$TimeLineControls/BPMWindow.visible = false
	$TimeLineControls/BPMWindow/BPMField.text = ""

func _on_delete_bpm_change_pressed():
	if Global.beat_change_cursor:
		if Global.beat_change_cursor.beat != 0:
			Global.beat_change_cursor.free()
	timeline_object_update()
	timeline_render("all")
	$TimeLineControls/BPMWindow.visible = false
	$TimeLineControls/BPMWindow/BPMField.text = ""

func _on_delete_bd_change_pressed():
	if Global.beat_change_cursor:
		if Global.beat_change_cursor.beat != 0:
			Global.beat_change_cursor.free()
	timeline_object_update()
	timeline_render("all")
	$TimeLineControls/BeatDivisorWindow.visible = false
	$TimeLineControls/BeatDivisorWindow/BeatDivisorField.text = ""

func _on_bpm_node_clicked(node):
	Global.beat_change_cursor = node
	add_bpm_window_show()
	
func _on_bd_node_clicked(node):
	Global.beat_change_cursor = node
	add_bd_window_show()


# we got them zoomies
func _on_zoom_up_pressed():
	if Global.timeline_zoom < 8:
		Global.timeline_zoom *= 2

func _on_zoom_down_pressed():
	if Global.timeline_zoom > 0.125:
		Global.timeline_zoom *= 0.5


func _on_button_pressed(): # debug button
	#print(Global.timeline_beats) # whys there a 0 in the end
	#print(timeline_bar_time) # error'd
	print($BPMChanges.get_children().size())
	print("Current time:",current_time)
	print("Beat:", time_to_beat(current_time))
	print(timeline_bar_time)






