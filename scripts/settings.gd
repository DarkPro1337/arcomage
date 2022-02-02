extends Control

var config_path = "user://settings.ini"

onready var anim = $AnimationPlayer
onready var reset = $reset
onready var bg = $bg
# INTERACTIVE CONTROL ELEMENTS VARIABLES BELOW
# WINDOW SETTINGS
onready var window_settings = $tab/Graphics
onready var window_settings_button = $buttons_container/buttons_grid/window_settings
onready var fullscreen_block = $tab/Graphics/graphics/fullscreen
onready var fullscreen_button = $tab/Graphics/graphics/fullscreen/fullscreen_button
onready var borderless_button = $tab/Graphics/graphics/borderless/borderless_button
onready var window_width_edit = $tab/Graphics/graphics/window_res/width
onready var window_height_edit = $tab/Graphics/graphics/window_res/height
onready var vsync_button = $tab/Graphics/graphics/vsync/vsync_button
onready var intro_skip = $tab/Graphics/graphics/intro_skip
onready var intro_skip_button = $tab/Graphics/graphics/intro_skip/introskip_button
# SOUND SETTINGS
onready var sound_settings = $tab/Sound
onready var sound_settings_button = $buttons_container/buttons_grid/sound_settings
onready var master_volume = $tab/Sound/sound/master/master_slider
onready var music_volume = $tab/Sound/sound/music/music_slider
onready var sound_volume = $tab/Sound/sound/sounds/sounds_slider
onready var mute_sound = $tab/Sound/sound/mute/mute_sound
# STARTING CONDITIONS
onready var starting_conditions = $tab/Starting_Conditions
onready var starting_conditions_button = $buttons_container/buttons_grid/starting_conditions
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
onready var play_conditions = $tab/Play_Conditions
onready var play_conditions_button = $buttons_container/buttons_grid/play_conditions
onready var auto_bricks = $tab/Play_Conditions/main/autoget/bricks/level
onready var auto_gems = $tab/Play_Conditions/main/autoget/gems/level
onready var auto_recruits = $tab/Play_Conditions/main/autoget/recruits/level
onready var cards_in_hand = $tab/Play_Conditions/main/cardsnum_and_ai/cards_in_hand/level
onready var ai = $tab/Play_Conditions/main/cardsnum_and_ai/AI/mode
# VICTORY CONDITIONS
onready var victory_conditions = $tab/Victory_Conditions
onready var victory_conditions_button = $buttons_container/buttons_grid/victory_conditions
onready var win_tower = $tab/Victory_Conditions/main/tower/level
onready var win_resources = $tab/Victory_Conditions/main/resource/level
# TAVERN PRESETS
onready var tavern_presets = $tab/Tavern_Presets
onready var tavern_presets_button = $buttons_container/buttons_grid/tavern_presets
onready var tavern_preset = $tab/Tavern_Presets/main/preset/tavern_option
# LANGUAGE SETTINGS
onready var language_settings = $tab/Language_Settings
onready var language_settings_button = $buttons_container/buttons_grid/language_settings
onready var language = $tab/Language_Settings/main/language/lang_option
onready var lang_errors = $tab/Language_Settings/main/lang_errors
# PLAYER SETTINGS
onready var player_settings = $tab/Player_Settings
onready var player_settings_button = $buttons_container/buttons_grid/player_settings
onready var nickname = $tab/Player_Settings/main/nickname/edit

func _ready():
	# Settings will looks different if you will open them from ingame menu
	if get_parent().name == "ingame_menu":
		starting_conditions_button.hide()
		play_conditions_button.hide()
		victory_conditions_button.hide()
		tavern_presets_button.hide()
		player_settings_button.hide()
		language_settings_button.hide()
		intro_skip.hide()
		reset.hide()
	elif get_parent().name != "main_menu":
		hide()
	
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
		4:
			TranslationServer.set_locale("da")

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
		# PLAYER SETTINGS
		c.set_value("PLAYER", "nickname", cfg.nickname)
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
		# PLAYER SETTINGS
		c.set_value("PLAYER", "nickname", nickname.text)
		c.save(config_path)

func load_settings():
	var c = ConfigFile.new()
	var err = c.load(config_path)
	# APPLY CURRENT SETTINGS FROM .INI FILE
	if err == OK:
		# WINDOW SETTINGS
		has_key_else_set(c, "WINDOW", "fullscreen", fullscreen_button.pressed)
		cfg.fullscreen = c.get_value("WINDOW", "fullscreen")
		has_key_else_set(c, "WINDOW", "borderless", borderless_button.pressed)
		cfg.borderless = c.get_value("WINDOW", "borderless")
		has_key_else_set(c, "WINDOW", "width", window_width_edit.text)
		cfg.window_width = c.get_value("WINDOW", "width")
		has_key_else_set(c, "WINDOW", "height", window_height_edit.text)
		cfg.window_height = c.get_value("WINDOW", "height")
		has_key_else_set(c, "WINDOW", "vsync", vsync_button.pressed)
		cfg.vsync = c.get_value("WINDOW", "vsync")
		has_key_else_set(c, "WINDOW", "intro_skip", intro_skip_button.pressed)
		cfg.intro_skip = c.get_value("WINDOW", "intro_skip")
		# AUDIO SETTINGS
		has_key_else_set(c, "AUDIO", "master", master_volume.value)
		cfg.master_volume = c.get_value("AUDIO", "master")
		has_key_else_set(c, "AUDIO", "music", music_volume.value)
		cfg.music_volume = c.get_value("AUDIO", "music")
		has_key_else_set(c, "AUDIO", "sounds", sound_volume.value)
		cfg.sound_volume = c.get_value("AUDIO", "sounds")
		has_key_else_set(c, "AUDIO", "mute", mute_sound.pressed)
		cfg.mute_sound = c.get_value("AUDIO", "mute")
		# STARTING CONDITIONS
		has_key_else_set(c, "START", "singleplayer", singleplayer_button.pressed)
		cfg.singleplayer = c.get_value("START", "singleplayer")
		has_key_else_set(c, "START", "single_click_mode", single_click_mode_button.pressed)
		cfg.single_click = c.get_value("START", "single_click_mode")
		has_key_else_set(c, "START", "mute_sound", mute_sound.pressed)
		cfg.mute_sound = c.get_value("START", "mute_sound")
		has_key_else_set(c, "START", "tower_levels", tower_levels.value)
		cfg.tower_levels = c.get_value("START", "tower_levels")
		has_key_else_set(c, "START", "wall_levels", wall_levels.value)
		cfg.wall_levels = c.get_value("START", "wall_levels")
		has_key_else_set(c, "START", "quarry_levels", quarry_levels.value)
		cfg.quarry_levels = c.get_value("START", "quarry_levels")
		has_key_else_set(c, "START", "brick_quantity", brick_quantity.value)
		cfg.brick_quantity = c.get_value("START", "brick_quantity")
		has_key_else_set(c, "START", "magic_levels", magic_levels.value)
		cfg.magic_levels = c.get_value("START", "magic_levels")
		has_key_else_set(c, "START", "gem_quantity", gem_quantity.value)
		cfg.gem_quantity = c.get_value("START", "gem_quantity")
		has_key_else_set(c, "START", "dungeon_levels", dungeon_levels.value)
		cfg.dungeon_levels = c.get_value("START", "dungeon_levels")
		has_key_else_set(c, "START", "recruit_quantity", recruit_quantity.value)
		cfg.recruit_quantity = c.get_value("START", "recruit_quantity")
		# PLAY CONDITIONS
		has_key_else_set(c, "PLAY", "auto_bricks", auto_bricks.value)
		cfg.auto_bricks = c.get_value("PLAY", "auto_bricks")
		has_key_else_set(c, "PLAY", "auto_gems", auto_gems.value)
		cfg.auto_gems = c.get_value("PLAY", "auto_gems")
		has_key_else_set(c, "PLAY", "auto_recruits", auto_recruits.value)
		cfg.auto_recruits = c.get_value("PLAY", "auto_recruits")
		has_key_else_set(c, "PLAY", "cards_in_hand", cards_in_hand.value)
		cfg.cards_in_hand = c.get_value("PLAY", "cards_in_hand")
		has_key_else_set(c, "PLAY", "ai", ai.selected)
		cfg.ai_type = c.get_value("PLAY", "ai")
		# VICTORY CONDITIONS
		has_key_else_set(c, "VICTORY", "tower_victory", win_tower.value)
		cfg.tower_victory = c.get_value("VICTORY", "tower_victory")
		has_key_else_set(c, "VICTORY", "resource_victory", win_resources.value)
		cfg.resource_victory = c.get_value("VICTORY", "resource_victory")
		# TAVERN PRESETS
		has_key_else_set(c, "TAVERN", "preset", tavern_preset.selected)
		cfg.current_tavern = c.get_value("TAVERN", "preset")
		# LANGUAGE SETTINGS
		has_key_else_set(c, "LANGUAGE", "locale", language.selected)
		cfg.locale = c.get_value("LANGUAGE", "locale")
		# PLAYER SETTINGS
		has_key_else_set(c, "PLAYER", "nickname", nickname.text)
		cfg.nickname = c.get_value("PLAYER", "nickname")

func has_key_else_set(c: ConfigFile, SECTION: String, key: String, set_to):
	if not c.has_section_key(SECTION, key): 
		c.set_value(SECTION, key, set_to)

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
	#singleplayer_button.pressed = cfg.singleplayer
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
	# PLAYER SETTINGS
	nickname.text = cfg.nickname

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

func _on_player_settings_pressed():
	$tab.current_tab = 7

func _on_fullscreen_button_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	if button_pressed == true:
		$tab/Graphics/graphics/window_res.hide()
	else:
		$tab/Graphics/graphics/window_res.show()

func _on_borderless_button_toggled(button_pressed):
	OS.window_borderless = button_pressed
	if button_pressed == true and fullscreen_button.pressed == true:
		fullscreen_block.hide()
	else:
		fullscreen_block.show()

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
			lang_errors.hide()
		1:
			TranslationServer.set_locale("ru")
			lang_errors.hide()
		2:
			TranslationServer.set_locale("uk")
			lang_errors.show()
		3:
			TranslationServer.set_locale("pl")
			lang_errors.show()
		4:
			TranslationServer.set_locale("da")
			lang_errors.show()

func _on_cards_in_hand_value_changed(value):
	cfg.cards_in_hand = value

func _on_tower_levels_value_changed(value):
	cfg.tower_levels = value

func _on_wall_levels_value_changed(value):
	cfg.wall_levels = value

func _on_introskip_button_toggled(button_pressed):
	cfg.intro_skip = button_pressed

func _on_nickname_text_changed(new_text):
	cfg.nickname = new_text

func _on_AI_mode_changed(index):
	cfg.ai_type = index
