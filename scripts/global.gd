extends Node

var table
var settings

func _input(event):
	if Input.is_action_just_pressed("ui_reset"):
		get_tree().reload_current_scene()
