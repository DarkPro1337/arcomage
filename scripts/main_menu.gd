extends Control

onready var settings = $settings
onready var network_setup = $network_setup
onready var startup = $startupAnim
onready var anim = $menuAnim
onready var info = $info
onready var version = $ver
onready var build_number = $build

func _ready():
	version.text = "v." + str(ProjectSettings.get_setting("application/config/version"))
	build_number.text = "Build: " + str(global.build)
	get_tree().paused = false
	#$menu_grid/new_game.emit_signal("pressed")
	print(global.time() + "Main menu loaded.")

func _on_new_game_pressed():
	anim.play("fade_out")
	yield(anim, "animation_finished")
	get_tree().change_scene("res://scenes/table.tscn")

func _on_multiplayer_game_pressed():
	network_setup.show()

func _on_settings_pressed():
	settings.show()
	anim.play("settings_show")

func _on_scores_pressed():
	alert(tr("WORK_IN_PROGRESS"), "Oops")

func _on_exit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	info.show()

func alert(text: String, title: String='Message') -> void:
	var dialog = AcceptDialog.new()
	dialog.theme = load("res://themes/main_menu_theme.tres")
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	add_child(dialog)
	dialog.popup_centered()
