extends Control

@onready var settings_ingame = $settings

func _ready():
	self.set_as_top_level(true)

func _on_resume_pressed():
	self.hide()
	global.table.get_tree().paused = false

func _on_settings_pressed():
	settings_ingame.show()

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
