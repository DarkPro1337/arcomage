extends Control

func _on_new_game_pressed():
	get_tree().change_scene("res://scenes/table.tscn")

func _on_settings_pressed():
	pass #TODO

func _on_scores_pressed():
	pass #TODO

func _on_exit_pressed():
	get_tree().quit()
