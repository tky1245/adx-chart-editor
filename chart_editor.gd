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
	var file = FileAccess.open(Global.CURRENT_CHART_PATH, FileAccess.WRITE_READ)
	load_external_song(Global.CURRENT_SONG_PATH)
	song_length = $AudioPlayers/TrackPlayer.stream.get_length() #um
	$PlaybackControls/TimeSlider/ProgressBar.max_value = song_length
	get_node("FileOptions/MenuButton").get_popup().connect("index_pressed", _on_option_pressed)
	
	# Draw a circle
	var center = Vector2(425, 250)
	var radius = 200
	var density = 180
	for k in range(density):
		var dotx = radius * sin(2 * PI * k / density) + center.x
		var doty = radius * cos(2 * PI * k / density) + center.y
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
	
	timeline_visible_range_update()
	timeline_object_update()
	timeline_render("all")
	

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
		timeline_visible_range_update()
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
		timeline_visible_range_update()
		timeline_render("all")
		if event is InputEventMouseButton and !event.pressed:
			timeline_dragging = false
		
func _process(delta):
	if !$Timeline/SongTimer.is_stopped():
		current_time = song_length - $Timeline/SongTimer.time_left
	$PlaybackControls/TimeSlider/ProgressBar.value = current_time
	$PlaybackControls/ElapsedTime.text = time_format(current_time)
	timeline_visible_range_update()
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
	
	var time_string: String
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
		var ogg = AudioStreamOggVorbis.new()
		ogg.load_from_buffer(file.get_buffer(file.get_length()))
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

func time_to_timeline_pos_x(time): # convert time to pos_x on timeline
	if time <= Global.timeline_visible_time_range["End"] and time >= Global.timeline_visible_time_range["Start"]:
		var pos_x = Global.timeline_leftmost_x + (Global.timeline_rightmost_x - Global.timeline_leftmost_x) / (Global.timeline_visible_time_range["End"] - Global.timeline_visible_time_range["Start"]) * (time - Global.timeline_visible_time_range["Start"])
		return pos_x
	else:
		return 0

# Use when editing notes
func timeline_object_update(): # read nodes(bpm/divisor) then update timeline_beats and timeline_bar_time
	#TODO: put note reader in
	var BPMDivisorArray: Array = [] # ["Mode": "BPM"/"BD", "Beat": int, "Value": float/int]
	if $BPMChanges.get_child_count() == 0: # No BPM?
		BPMDivisorArray.append({"Mode": "BPM", "Beat": 0, "Value": 160})
	else:
		for BPMNode in $BPMChanges.get_children():
			BPMDivisorArray.append({"Mode": "BPM", "Beat": BPMNode.beat, "Value": BPMNode.BPM})
	if $BeatDivisorChanges.get_child_count() == 0:
		BPMDivisorArray.append({"Mode": "BD", "Beat": 0, "Value": 4})
	else:
		for BDNode in $BeatDivisorChanges.get_children():
			BPMDivisorArray.append({"Mode": "BD", "Beat": BDNode.beat, "Value": BDNode.beat_divisor})
	arrange_by_beat(BPMDivisorArray)
	
	var temp_time: float = 0
	var temp_BPM = 0
	var temp_beat_divisor = 0
	var temp_beat = 0
	var array_counter = 0
	while temp_time < song_length:
		for item in BPMDivisorArray.slice(array_counter): # Read BPM/Divisor change and check if theres one on current beat
			if item["Beat"] == temp_beat:
				if item["Mode"] == "BPM":
					temp_BPM = item["Value"]
				elif item["Mode"] == "BD":
					temp_beat_divisor = item["Value"]
			if item["Beat"] <= temp_beat:
				array_counter += 1
			else:
				break
		Global.timeline_beats.append(temp_time)
		temp_time += (60.0 / temp_BPM) / temp_beat_divisor
		temp_beat += 1
	
	temp_time = 0
	temp_BPM = 0
	array_counter = 0
	while temp_time < song_length:
		for item in BPMDivisorArray.slice(array_counter): # correct next bar line to bpm change if theres one in the way
			if item["Mode"] == "BPM":
				if temp_time >= Global.timeline_beats[item["Beat"]]:
					temp_time = Global.timeline_beats[item["Beat"]]
					temp_BPM = item["Value"]
					array_counter += 1
				if temp_time > Global.timeline_beats[item["Beat"]]:
					break
		timeline_bar_time.append(temp_time)
		temp_time += 60.0 / temp_BPM * beats_per_bar
	for line in $TimelineBars.get_children():
		line.queue_free()
	for bar_num in range(timeline_bar_time.size()):
		var newLine = load("res://note detail stuffs/timeline_bar_line.tscn").instantiate()
		newLine.name = "Bar" + str(bar_num)
		newLine.time = timeline_bar_time[bar_num]
		newLine.add_point(Vector2(120, 516))
		newLine.add_point(Vector2(120, 648))
		newLine.default_color = Color.DARK_GREEN
		newLine.width = 2
		$TimelineBars.add_child(newLine)
	timeline_render("bar")

func arrange_by_beat(arr): # Bubble sort
	var swapped = false
	for i in range(len(arr)):
		swapped = false
		for j in range(len(arr) - 1):
			if arr[j]["Beat"] > arr[j + 1]["Beat"]:
				var temp = arr[j]["Beat"] # dumb swapping
				arr[j]["Beat"] = arr[j + 1]["Beat"]
				arr[j + 1]["Beat"] = temp
				swapped = true
		if swapped == false:
			break

func timeline_render(type: String): # Render objects on timeline
	if type == "bar":

		for line in $TimelineBars.get_children():
			var idx = int(str(line.name).erase(2))
			if line.time > Global.timeline_visible_time_range["Start"] and line.time < Global.timeline_visible_time_range["End"]:
				line.visible = true
				line.set_point_position(0, Vector2(time_to_timeline_pos_x(timeline_bar_time[idx]), 516))
				line.set_point_position(1, Vector2(time_to_timeline_pos_x(timeline_bar_time[idx]), 648))
			else:
				line.visible = false
	else: # Default, render everything 
		timeline_render("bar")

func time_to_beat(time: float): # Snaps time to beat
	for beat_time in Global.timeline_beats:
		if time > beat_time:
			return Global.timeline_beats.find(beat_time)

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
		if !Global.beat_change_cursor:
			var beat_divisor_node = preload("res://note detail stuffs/beat_divisor_node.tscn")
			var new_node = beat_divisor_node.instantiate()
			new_node.beat_divisor = beat_divisor
			new_node.beat = time_to_beat(current_time)
			new_node.connect("bpm_button_clicked", _on_bpm_node_clicked)
			$BeatDivisorChanges.add_child(new_node)
		else:
			var node = Global.beat_change_cursor
			node.beat_divisor = beat_divisor
	$TimeLineControls/BeatDivisorWindow.visible = false
	$TimeLineControls/BeatDivisorWindow/BeatDivisorField.text = ""

func _on_bpm_field_text_submitted(new_text):
	var bpm = int(new_text)
	if bpm > 0:
		if !Global.beat_change_cursor:
			var bpm_node = preload("res://note detail stuffs/bpm_node.tscn")
			var new_node = bpm_node.instantiate()
			new_node.bpm = bpm
			new_node.beat = time_to_beat(current_time)
			new_node.connect("bd_button_clicked", _on_bd_node_clicked)
			$BPMChanges.add_child(new_node)
		else:
			var node = Global.beat_change_cursor
			node.bpm = bpm
	$TimeLineControls/BPMWindow.visible = false
	$TimeLineControls/BPMWindow/BPMField.text = ""

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
