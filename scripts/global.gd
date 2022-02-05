extends Node

var table
var settings
var build

var player_info = {
	name = "Player",
	net_id = 1
}

func _ready():
	OS.set_low_processor_usage_mode(true)
	build = load_build_number()

func time():
	var hour = str(OS.get_time().get("hour"))
	var minute = str(OS.get_time().get("minute"))
	var second = str(OS.get_time().get("second"))
	return "[" + hour + ":" + minute + ":" + second + "] "

#func _input(event):
#	if Input.is_action_just_pressed("ui_reset"):
#		get_tree().reload_current_scene()

func load_build_number():
	var file = File.new()
	if file.file_exists("res://build.tres"):
		file.open("res://build.tres", File.READ)
		var content = file.get_as_text()
		file.close()
		return content
	else:
		return "ERROR"
		print("Warning! build.tres file missing.")
