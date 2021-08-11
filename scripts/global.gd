extends Node

var table
var settings
var build

func _ready():
	OS.set_low_processor_usage_mode(true)
	build = load_build_number()

func _input(event):
	if Input.is_action_just_pressed("ui_reset"):
		get_tree().reload_current_scene()

func load_build_number():
	var file = File.new()
	if file.file_exists("res://build.dat"):
		file.open("res://build.dat", File.READ)
		var content = file.get_as_text()
		file.close()
		return content
	else:
		return "ERROR"
		print("Warning! build.dat file missing.")
