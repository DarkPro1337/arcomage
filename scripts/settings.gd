extends Control

var config_path = "user://settings.ini"

onready var anim = $AnimationPlayer
# INTERACTIVE CONTROL ELEMENTS VARIABLES BELOW
# WINDOW SETTINGS
onready var fullscreen_button = $tab/Graphics/graphics/fullscreen/fullscreen_button
onready var borderless_button = $tab/Graphics/graphics/borderless/borderless_button
onready var window_width_edit = $tab/Graphics/graphics/window_res/width
onready var window_height_edit = $tab/Graphics/graphics/window_res/height
onready var vsync_button = $tab/Graphics/graphics/vsync/vsync_button
onready var intro_skip_button = $tab/Graphics/graphics/intro_skip/introskip_button
# SOUND SETTINGS
onready var master_volume = $tab/Sound/sound/master/master_slider
onready var music_volume = $tab/Sound/sound/music/music_slider
onready var sound_volume = $tab/Sound/sound/sounds/sounds_slider
onready var mute_sound = $tab/Sound/sound/mute/mute_sound
# STARTING CONDITIONS
onready var singleplayer_button = $tab/Starting_Conditions/starting_conditions/main/gameplay/single_player/singleplayer
onready var multiplayer_button = $tab/Starting_Conditions/starting_conditions/main/gameplay/multi_player/multiplayer
onready var single_click_mode_button = $tab/Starting_Conditions/starting_conditions/main/gameplay/single_click/singleclick_mode
onready var tower_levels = $tab/Starting_Conditions/starting_conditions/main/towers_walls/tower_levels/level
onready var wall_levels = $tab/Starting_Conditions/starting_conditions/main/towers_walls/wall_levels/level
onready var quarry_levels = $tab/Starting_Conditions/starting_conditions/gen_res/generators/quarry_levels/level
onready var brick_quantity = $tab/Starting_Conditions/starting_conditions/gen_res/resources/brick_quanity/level
onready var magic_levels = $tab/Starting_Conditions/starting_conditions/gen_res/generators/magic_levels/level
onready var gem_quantity = $tab/Starting_Conditions/starting_conditions/gen_res/resources/gem_quanity/level
onready var dungeon_levels = $tab/Starting_Conditions/starting_conditions/gen_res/generators/dungeon_levels3/level
onready var recruit_quantity = $tab/Starting_Conditions/starting_conditions/gen_res/resources/recruit_quanity/level
# PLAY CONDITIONS
onready var auto_bricks = $tab/Play_Conditions/main/autoget/bricks/level
onready var auto_gems = $tab/Play_Conditions/main/autoget/gems/level
onready var auto_recruits = $tab/Play_Conditions/main/autoget/recruits/level
onready var cards_in_hand = $tab/Play_Conditions/main/cardsnum_and_ai/cards_in_hand/level
onready var ai = $tab/Play_Conditions/main/cardsnum_and_ai/AI/mode
# VICTORY CONDITIONS
onready var win_tower = $tab/Victory_Conditions/main/tower/level
onready var win_resources = $tab/Victory_Conditions/main/resource/level
# TAVERN PRESETS
onready var tavern_preset = $tab/Tavern_Presets/main/preset/tavern_option
# LANGUAGE SETTINGS
onready var language = $tab/Language_Settings/main/language/lang_option

func _ready():
	load_settings()
	update_controls()
	$tab/Graphics/graphics/window_res/height.text = str(OS.get_window_size().y)
	$tab/Graphics/graphics/window_res/width.text = str(OS.get_window_size().x)
	match cfg.locale:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("ru")
		2:
			TranslationServer.set_locale("uk")
		3:
			TranslationServer.set_locale("pl")

func _on_close_pressed():
	anim.play("hide")
	yield(anim, "animation_finished")
	save_settings()
	hide()

func save_settings():
	var c = ConfigFile.new()
	var err = c.load(config_path)
	# IF FILE DIDN'T EXIST - CREATE NEW ONE WITH DEFAULT SETTINGS
	if err != OK:
		# WINDOW SETTINGS
		c.set_value("WINDOW", "fullscreen", cfg.fullscreen)
		c.set_value("WINDOW", "borderless", cfg.borderless)
		c.set_value("WINDOW", "width", cfg.window_width)
		c.set_value("WINDOW", "height", cfg.window_height)
		c.set_value("WINDOW", "vsync", cfg.vsync)
		c.set_value("WINDOW", "intro_skip", cfg.intro_skip)
		# AUDIO SETTINGS
		c.set_value("AUDIO", "master", cfg.master_volume)
		c.set_value("AUDIO", "music", cfg.music_volume)
		c.set_value("AUDIO", "sounds", cfg.sound_volume)
		c.set_value("AUDIO", "mute", cfg.mute_sound)
		# STARTING CONDITIONS
		c.set_value("START", "singleplayer", cfg.singleplayer)
		c.set_value("START", "single_click_mode", cfg.single_click)
		c.set_value("START", "mute_sound", cfg.mute_sound)
		c.set_value("START", "tower_levels", cfg.tower_levels)
		c.set_value("START", "wall_levels", cfg.wall_levels)
		c.set_value("START", "quarry_levels", cfg.quarry_levels)
		c.set_value("START", "brick_quantity", cfg.brick_quantity)
		c.set_value("START", "magic_levels", cfg.magic_levels)
		c.set_value("START", "gem_quantity", cfg.gem_quantity)
		c.set_value("START", "dungeon_levels", cfg.dungeon_levels)
		c.set_value("START", "recruit_quantity", cfg.recruit_quantity)
		# PLAY CONDITIONS
		c.set_value("PLAY", "auto_bricks", cfg.auto_bricks)
		c.set_value("PLAY", "auto_gems", cfg.auto_gems)
		c.set_value("PLAY", "auto_recruits", cfg.auto_recruits)
		c.set_value("PLAY", "cards_in_hand", cfg.cards_in_hand)
		c.set_value("PLAY", "ai", cfg.ai_type)
		# VICTORY CONDITIONS
		c.set_value("VICTORY", "tower_victory", cfg.tower_victory)
		c.set_value("VICTORY", "resource_victory", cfg.resource_victory)
		# TAVERN PRESETS
		c.set_value("TAVERN", "preset", cfg.current_tavern)
		# LANGUAGE SETTINGS
		c.set_value("LANGUAGE", "locale", cfg.locale)
		c.save(config_path)
	# IF FILE EXISTS - REWRITE KEY VALUES
	elif err == OK:
		# WINDOW SETTINGS
		c.set_value("WINDOW", "fullscreen", fullscreen_button.pressed)
		c.set_value("WINDOW", "borderless", borderless_button.pressed)
		c.set_value("WINDOW", "width", int(window_width_edit.text))
		c.set_value("WINDOW", "height", int(window_height_edit.text))
		c.set_value("WINDOW", "vsync", vsync_button.pressed)
		c.set_value("WINDOW", "intro_skip", intro_skip_button.pressed)
		# AUDIO SETTINGS
		c.set_value("AUDIO", "master", master_volume.value)
		c.set_value("AUDIO", "music", music_volume.value)
		c.set_value("AUDIO", "sounds", sound_volume.value)
		c.set_value("AUDIO", "mute", mute_sound.pressed)
		# STARTING CONDITIONS
		c.set_value("START", "singleplayer", singleplayer_button.pressed)
		c.set_value("START", "single_click_mode", single_click_mode_button.pressed)
		c.set_value("START", "mute_sound", mute_sound.pressed)
		c.set_value("START", "tower_levels", int(tower_levels.value))
		c.set_value("START", "wall_levels", int(wall_levels.value))
		c.set_value("START", "quarry_levels", int(quarry_levels.value))
		c.set_value("START", "brick_quantity", int(brick_quantity.value))
		c.set_value("START", "magic_levels", int(magic_levels.value))
		c.set_value("START", "gem_quantity", int(gem_quantity.value))
		c.set_value("START", "dungeon_levels", int(dungeon_levels.value))
		c.set_value("START", "recruit_quantity", int(recruit_quantity.value))
		c.set_value("PLAY", "ai", ai.selected)
		# PLAY CONDITIONS
		c.set_value("PLAY", "auto_bricks", int(auto_bricks.value))
		c.set_value("PLAY", "auto_gems", int(auto_gems.value))
		c.set_value("PLAY", "auto_recruits", int(auto_recruits.value))
		c.set_value("PLAY", "cards_in_hand", int(cards_in_hand.value))
		# VICTORY CONDITIONS
		c.set_value("VICTORY", "tower_victory", int(win_tower.value))
		c.set_value("VICTORY", "resource_victory", int(win_resources.value))
		# TAVERN PRESETS
		c.set_value("TAVERN", "preset", tavern_preset.selected)
		# LANGUAGE SETTINGS
		c.set_value("LANGUAGE", "locale", language.selected)
		c.save(config_path)

func load_settings():
	var c = ConfigFile.new()
	var err = c.load(config_path)
	# APPLY CURRENT SETTINGS FROM .INI FILE
	if err == OK:
		# WINDOW SETTINGS
		cfg.fullscreen = c.get_value("WINDOW", "fullscreen")
		cfg.borderless = c.get_value("WINDOW", "borderless")
		cfg.window_width = c.get_value("WINDOW", "width")
		cfg.window_height = c.get_value("WINDOW", "height")
		cfg.vsync = c.get_value("WINDOW", "vsync")
		cfg.intro_skip = c.get_value("WINDOW", "intro_skip")
		# AUDIO SETTINGS
		cfg.master_volume = c.get_value("AUDIO", "master")
		cfg.music_volume = c.get_value("AUDIO", "music")
		cfg.sound_volume = c.get_value("AUDIO", "sounds")
		cfg.mute_sound = c.get_value("AUDIO", "mute")
		# STARTING CONDITIONS
		cfg.singleplayer = c.get_value("START", "singleplayer")
		cfg.single_click = c.get_value("START", "single_click_mode")
		cfg.mute_sound = c.get_value("START", "mute_sound")
		cfg.tower_levels = c.get_value("START", "tower_levels")
		cfg.wall_levels = c.get_value("START", "wall_levels")
		cfg.quarry_levels = c.get_value("START", "quarry_levels")
		cfg.brick_quantity = c.get_value("START", "brick_quantity")
		cfg.magic_levels = c.get_value("START", "magic_levels")
		cfg.gem_quantity = c.get_value("START", "gem_quantity")
		cfg.dungeon_levels = c.get_value("START", "dungeon_levels")
		cfg.recruit_quantity = c.get_value("START", "recruit_quantity")
		# PLAY CONDITIONS
		cfg.auto_bricks = c.get_value("PLAY", "auto_bricks")
		cfg.auto_gems = c.get_value("PLAY", "auto_gems")
		cfg.auto_recruits = c.get_value("PLAY", "auto_recruits")
		cfg.cards_in_hand = c.get_value("PLAY", "cards_in_hand")
		cfg.ai_type = c.get_value("PLAY", "ai")
		# VICTORY CONDITIONS
		cfg.tower_victory = c.get_value("VICTORY", "tower_victory")
		cfg.resource_victory = c.get_value("VICTORY", "resource_victory")
		# TAVERN PRESETS
		cfg.current_tavern = c.get_value("TAVERN", "preset")
		# LANGUAGE SETTINGS
		cfg.locale = c.get_value("LANGUAGE", "locale")

# UPDATE BUTTONS STATE
func update_controls():
	# WINDOW SETTINGS
	fullscreen_button.pressed = cfg.fullscreen
	borderless_button.pressed = cfg.borderless
	window_width_edit.text = str(cfg.window_width)
	window_height_edit.text = str(cfg.window_height)
	vsync_button.pressed = cfg.vsync
	intro_skip_button.pressed = cfg.intro_skip
	# AUDIO SETTINGS
	master_volume.value = float(cfg.master_volume)
	music_volume.value = float(cfg.music_volume)
	sound_volume.value = float(cfg.sound_volume)
	mute_sound.pressed = cfg.mute_sound
	# STARTING CONDITIONS
	#TODO: SINGLEPLAYER AND MULTIPLAYER RADIO BUTTONS STATE, AFTER MULTIPLAYER UPDATE
	single_click_mode_button.pressed = cfg.single_click
	mute_sound.pressed = cfg.mute_sound
	tower_levels.value = cfg.tower_levels
	wall_levels.value = cfg.wall_levels
	quarry_levels.value = cfg.quarry_levels
	brick_quantity.value = cfg.brick_quantity
	magic_levels.value = cfg.magic_levels
	gem_quantity.value = cfg.gem_quantity
	dungeon_levels.value = cfg.dungeon_levels
	recruit_quantity.value = cfg.recruit_quantity
	# PLAY CONDITIONS
	auto_bricks.value = cfg.auto_bricks
	auto_gems.value = cfg.auto_gems
	auto_recruits.value = cfg.auto_recruits
	cards_in_hand.value = cfg.cards_in_hand
	ai.selected = cfg.ai_type
	# VICTORY CONDITIONS
	win_tower.value = cfg.tower_victory
	win_resources.value = cfg.resource_victory
	# TAVERN PRESETS
	tavern_preset.selected = cfg.current_tavern
	# LANGUAGE
	language.selected = cfg.locale

func _on_window_pressed():
	$tab.current_tab = 0

func _on_sound_settings_pressed():
	$tab.current_tab = 1

func _on_starting_conditions_pressed():
	$tab.current_tab = 2

func _on_play_conditions_pressed():
	$tab.current_tab = 3

func _on_victory_conditions_pressed():
	$tab.current_tab = 4

func _on_tavern_presets_pressed():
	$tab.current_tab = 5

func _on_language_settings_pressed():
	$tab.current_tab = 6

func _on_fullscreen_button_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	if button_pressed == true:
		$tab/Graphics/graphics/window_res.hide()
	else:
		$tab/Graphics/graphics/window_res.show()

func _on_borderless_button_toggled(button_pressed):
	OS.window_borderless = button_pressed

func _on_vsync_button_toggled(button_pressed):
	OS.vsync_enabled = button_pressed

func _on_winres_apply_pressed():
	OS.set_window_size(Vector2(float(window_width_edit.text), float(window_height_edit.text)))
	OS.set_window_position(OS.get_screen_size()*0.5 - OS.get_window_size()*0.5)

func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear2db(master_volume.value))

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear2db(music_volume.value))

func _on_sounds_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear2db(sound_volume.value))

func _on_lang_option_item_selected(index):
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("ru")
		2:
			TranslationServer.set_locale("uk")
		3:
			TranslationServer.set_locale("pl")

func _on_cards_in_hand_value_changed(value):
	cfg.cards_in_hand = value

func _on_tower_levels_value_changed(value):
	cfg.tower_levels = value

func _on_wall_levels_value_changed(value):
	cfg.wall_levels = value

func _on_introskip_button_toggled(button_pressed):
	cfg.intro_skip = button_pressed
