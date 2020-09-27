extends Control

onready var anim = $AnimationPlayer

func _on_close_pressed():
	anim.play("hide")
	yield(anim, "animation_finished")
	hide()

func _on_window_pressed():
	$tab.current_tab = 0

func _on_starting_conditions_pressed():
	$tab.current_tab = 1

func _on_play_conditions_pressed():
	$tab.current_tab = 2

func _on_victory_conditions_pressed():
	$tab.current_tab = 3

func _on_tavern_presets_pressed():
	$tab.current_tab = 4
