extends Control

onready var winner_nickname = $winner_label
onready var winned_by_what = $by_what
onready var playtime = $time
onready var anim = $anim

func _ready():
	self.set_as_toplevel(true)

func set_winner(nickname, by_what, time):
	show()
	winner_nickname.text = nickname
	winned_by_what.text = by_what
	playtime.text = "TIME: " + time

func _input(event):
	if Input.is_action_just_pressed("ui_select"):
		get_tree().paused = false
		$fader.set_as_toplevel(true)
		anim.play("fade_out")
		yield(anim, "animation_finished")
		get_tree().change_scene("res://scenes/main_menu.tscn")
