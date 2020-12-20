extends Node

var table
var settings

func _ready():
	OS.set_low_processor_usage_mode(true)

func _input(event):
	if Input.is_action_just_pressed("ui_reset"):
		get_tree().reload_current_scene()
