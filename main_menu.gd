extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_new_chart_pressed():
	if !$SelectSong.visible:
		$SelectSong.visible = true


func _on_select_song_file_selected(song_path):
	var temp_arr = song_path.split("/")
	var song_dir = song_path.erase(len(temp_arr[len(temp_arr)-1]))
	var chart_path = song_dir + "/chart.txt"
	
	Global.CURRENT_SONG_PATH = song_path
	Global.CURRENT_CHART_PATH = chart_path
	
	
	
	get_tree().change_scene_to_file("res://chart_editor.tscn")
