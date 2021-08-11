extends Control

func _on_anim_animation_finished(anim_name):
	if anim_name == "init":
		get_tree().change_scene("res://scenes/main_menu.tscn")
