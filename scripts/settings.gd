extends Control

onready var anim = $AnimationPlayer

var intro_skip

func _ready():
	$tab/Graphics/graphics/window_res/height.text = str(OS.get_window_size().y)
	$tab/Graphics/graphics/window_res/width.text = str(OS.get_window_size().x)

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

func _on_fullscreen_button_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	if button_pressed == true:
		$tab/Graphics/graphics/window_res.hide()
	else:
		$tab/Graphics/graphics/window_res.show()

func _on_borderless_button_toggled(button_pressed):
	OS.window_borderless = button_pressed

func _on_winres_apply_pressed():
	pass #TODO: MAKE WINRES CHANGE

func _on_vsync_button_toggled(button_pressed):
	OS.vsync_enabled = button_pressed

func _on_introskip_button_toggled(button_pressed):
	intro_skip = button_pressed
