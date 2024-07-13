extends Node2D
var song_name
var selected_song_path
var open_chart_selected_chart: int = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.root_folder:
		$SelectSong.root_subfolder = Global.root_folder
		$SelectMaidata.root_subfolder = Global.root_folder
		$SelectMaidataAndroid.root_subfolder = Global.root_folder

func _on_new_chart_pressed():
	if !$SelectSong.visible:
		$SelectSong.visible = true


func _on_select_song_file_selected(song_path):
	selected_song_path = song_path
	var temp_arr = song_path.split("/")
	var song_dir = song_path.erase(len(temp_arr[len(temp_arr)-1]))
	var chart_path = song_dir + "/chart.txt"
	
	Global.CURRENT_SONG_PATH = song_path
	Global.CURRENT_CHART_PATH = song_dir
	
	$NewChartSongName.visible = true

func _on_song_name_field_text_submitted(new_text):
	
	var song_name = new_text
	var track_format = "." + selected_song_path.get_slice(".", selected_song_path.count("."))
	Savefile.create_chart(song_name, selected_song_path)
	get_tree().change_scene_to_file("res://chart_editor.tscn")
	$NewChartSongName.visible = false
	$NewChartSongName/VBoxContainer/SongNameField.text = ""
	
func _on_new_chart_song_name_close_requested():
	$NewChartSongName.visible = false

func _on_open_chart_selection_close_requested():
	$OpenChartSelection.visible = false

func _on_open_chart_pressed():
	$OpenChartSelection.visible = true
	chart_dir_load()

func chart_dir_load():
	var dir = DirAccess.open(Global.CHART_STORAGE_PATH)
	for node in $OpenChartSelection/VBoxContainer/ScrollContainer/Charts.get_children():
		node.free()
	var index = 0
	for chart_name in dir.get_directories():
		var availlable_difficulty: Array = []
		var chart_artist: String
		var bpm: String
		var jacket
		for extension in Savefile.img_extensions:
			if dir.file_exists(Global.CHART_STORAGE_PATH + chart_name + "/bg" + extension):
				var img = Image.load_from_file(Global.CHART_STORAGE_PATH + chart_name + "/bg" + extension)
				jacket = ImageTexture.create_from_image(img)
				break
		if !jacket:
			jacket = load("res://bg_not_found.png")
		var file = FileAccess.open(Global.CHART_STORAGE_PATH + chart_name + "/chart.mai", FileAccess.READ)
		var json_string = file.get_line()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var data_received = json.data
			if typeof(data_received) == TYPE_DICTIONARY:
				for i in range(7):
					if data_received.get(str("inote_" + str(i+1))):
						availlable_difficulty.append(i+1)
				chart_artist = data_received.get("artist") if data_received.get("artist") else ""
				bpm = str(data_received.get("bpm")) if data_received.get("bpm") else ""
				
				var chart_select = preload("res://chart_select.tscn")
				var new_node = chart_select.instantiate()
				new_node.index = index
				new_node.initialize(chart_name, chart_artist, bpm, availlable_difficulty, jacket)
				new_node.connect("chart_clicked", chart_clicked, 8)
				$OpenChartSelection/VBoxContainer/ScrollContainer/Charts.add_child(new_node)
				index += 1
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		
	pass

func chart_clicked(node):
	if open_chart_selected_chart != node.index:
		open_chart_selected_chart = node.index
	for lbl in $OpenChartSelection/VBoxContainer/Options/VBoxContainer.get_children():
		lbl.free()
	for chart_select in $OpenChartSelection/VBoxContainer/ScrollContainer/Charts.get_children():
		chart_select.selected_toggle(open_chart_selected_chart == chart_select.index)
		if open_chart_selected_chart == chart_select.index:
			var bpm_lbl = Label.new()
			bpm_lbl.text = "BPM: " + str(chart_select.bpm) if chart_select.bpm else "BPM: -"
			bpm_lbl.add_theme_font_size_override("font_size", 28)
			$OpenChartSelection/VBoxContainer/Options/VBoxContainer.add_child(bpm_lbl)
			
			var artist_lbl = Label.new()
			artist_lbl.text = "Artist: " + str(chart_select.artist) if chart_select.artist else "Artist: -"
			artist_lbl.add_theme_font_size_override("font_size", 28)
			$OpenChartSelection/VBoxContainer/Options/VBoxContainer.add_child(artist_lbl)
	if open_chart_selected_chart or open_chart_selected_chart == 0:
		$OpenChartSelection/VBoxContainer/Options/BoxContainer2/SelectButton.visible = true
		$OpenChartSelection/VBoxContainer/Options/BoxContainer/DeleteButton.visible = true
		$OpenChartSelection/VBoxContainer/Options/BoxContainer3/RenameButton.visible = true
	else:
		$OpenChartSelection/VBoxContainer/Options/BoxContainer2/SelectButton.visible = false
		$OpenChartSelection/VBoxContainer/Options/BoxContainer/DeleteButton.visible = false
		$OpenChartSelection/VBoxContainer/Options/BoxContainer3/RenameButton.visible = false


func _on_select_button_pressed():
	print(str(open_chart_selected_chart))
	if open_chart_selected_chart != -1:
		for chart_select in $OpenChartSelection/VBoxContainer/ScrollContainer/Charts.get_children():
			if chart_select.index == open_chart_selected_chart:
				Global.current_chart_name = chart_select.title
				get_tree().change_scene_to_file("res://chart_editor.tscn")


func _on_delete_button_pressed():
	pass # Replace with function body.


func _on_rename_button_pressed():
	pass # Replace with function body.


func _on_select_maidata_file_selected(path):
	var dir = path.left(-len("maidata.txt"))
	if Savefile.import_maidata(dir):
		get_tree().change_scene_to_file("res://chart_editor.tscn")


func _on_import_from_maidata_pressed():
	$SelectMaidata.visible = true


func _on_import_from_maidata_android_pressed():
	$SelectMaidataAndroid.visible = true


func _on_select_maidata_android_dir_selected(dir):
	Savefile.import_maidata(dir)
	get_tree().change_scene_to_file("res://chart_editor.tscn")
