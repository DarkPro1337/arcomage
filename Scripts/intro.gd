extends Control

func _ready():
	print(global.time() + "Intro loaded.")

func _on_anim_animation_finished(anim_name):
	if anim_name == "init":
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		print(global.time() + "Loading to the Main menu...")
