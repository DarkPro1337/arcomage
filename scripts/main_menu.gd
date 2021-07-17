extends Control

onready var settings = $settings
onready var anim = $menuAnim
onready var info = $info

func _on_new_game_pressed():
	anim.play("fade_out")
	yield(anim, "animation_finished")
	get_tree().change_scene("res://scenes/table.tscn")

func _on_settings_pressed():
	settings.show()
	anim.play("settings_show")

func _on_scores_pressed():
	pass #TODO

func _on_exit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	info.show()
