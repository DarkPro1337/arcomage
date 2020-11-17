extends Control

var settings_file = "user://settings.save"
onready var anim = $AnimationPlayer
# INTERACTIVE CONTROL ELEMENTS VARIABLES BELOW
# WINDOW SETTINGS
onready var fullscreen_button = $tab/Graphics/graphics/fullscreen/fullscreen_button
onready var borderless_button = $tab/Graphics/graphics/borderless/borderless_button
onready var window_width_edit = $tab/Graphics/graphics/window_res/width
onready var window_height_edit = $tab/Graphics/graphics/window_res/height
onready var vsync_button = $tab/Graphics/graphics/vsync/vsync_button
onready var intro_skip_button = $tab/Graphics/graphics/intro_skip/introskip_button
# STARTING CONDITIONS
onready var singleplayer_button = $tab/Starting_Conditions/starting_conditions/main/gameplay/single_player/singleplayer
onready var multiplayer_button = $tab/Starting_Conditions/starting_conditions/main/gameplay/multi_player/multiplayer
onready var single_click_mode_button = $tab/Starting_Conditions/starting_conditions/main/gameplay/single_click/singleclick_mode
onready var mute_sound = $tab/Starting_Conditions/starting_conditions/main/gameplay/mute_sound/mute_sound
onready var tower_levels = $tab/Starting_Conditions/starting_conditions/main/towers_walls/tower_levels/level
onready var wall_levels = $tab/Starting_Conditions/starting_conditions/main/towers_walls/wall_levels/level
onready var quarry_levels = $tab/Starting_Conditions/starting_conditions/gen_res/generators/quarry_levels/level
onready var brick_quanity = $tab/Starting_Conditions/starting_conditions/gen_res/resources/brick_quanity/level
onready var magic_levels = $tab/Starting_Conditions/starting_conditions/gen_res/generators/magic_levels/level
onready var gem_quanity = $tab/Starting_Conditions/starting_conditions/gen_res/resources/gem_quanity/level
onready var dungeon_levels = $tab/Starting_Conditions/starting_conditions/gen_res/generators/dungeon_levels3/level
onready var recruit_quanity = $tab/Starting_Conditions/starting_conditions/gen_res/resources/recruit_quanity/level
# PLAY CONDITIONS
onready var auto_bricks = $tab/Play_Conditions/main/autoget/bricks/level
onready var auto_gems = $tab/Play_Conditions/main/autoget/gems/level
onready var auto_recruits = $tab/Play_Conditions/main/autoget/recruits/level
# VICTORY CONDITIONS
onready var win_tower = $tab/Victory_Conditions/main/tower/level
onready var win_resources = $tab/Victory_Conditions/main/resource/level
# TAVERN PRESETS
onready var tavern_preset = $tab/Tavern_Presets/main/preset/tavern_option

func _ready():
	load_settings()
	$tab/Graphics/graphics/window_res/height.text = str(OS.get_window_size().y)
	$tab/Graphics/graphics/window_res/width.text = str(OS.get_window_size().x)

func _on_close_pressed():
	anim.play("hide")
	yield(anim, "animation_finished")
	save_settings()
	hide()

func save_settings():
	var f = File.new()
	f.open(settings_file, File.WRITE)
	# WINDOW SETTINGS
	f.store_var(cfg.fullscreen)
	f.store_var(cfg.borderless)
	f.store_var(cfg.window_width)
	f.store_var(cfg.window_height)
	f.store_var(cfg.vsync)
	f.store_var(cfg.intro_skip)
	# STARTING CONDITIONS
	f.store_var(cfg.singleplayer)
	f.store_var(cfg.single_click)
	f.store_var(cfg.mute_sound)
	f.store_var(cfg.tower_levels)
	f.store_var(cfg.wall_levels)
	f.store_var(cfg.quarry_levels)
	f.store_var(cfg.brick_quanity)
	f.store_var(cfg.magic_levels)
	f.store_var(cfg.gem_quanity)
	f.store_var(cfg.dungeon_levels)
	f.store_var(cfg.recruit_quianity)
	# PLAY CONDITIONS
	f.store_var(cfg.auto_bricks)
	f.store_var(cfg.auto_gems)
	f.store_var(cfg.auto_recruits)
	f.store_var(cfg.cards_in_hand)
	f.store_var(cfg.ai_type)
	# VICTORY CONDITIONS
	f.store_var(cfg.tower_victory)
	f.store_var(cfg.resource_victory)
	# TAVERN PRESETS
	f.store_var(cfg.current_tavern)
	f.close()

func load_settings():
	var f = File.new()
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ)
		# WINDOW SETTINGS
		cfg.fullscreen = f.get_var()
		cfg.borderless = f.get_var()
		cfg.window_width = f.get_var()
		cfg.window_height = f.get_var()
		cfg.vsync = f.get_var()
		cfg.intro_skip = f.get_var()
		# STARTING CONDITIONS
		cfg.singleplayer = f.get_var()
		cfg.single_click = f.get_var()
		cfg.mute_sound = f.get_var()
		cfg.tower_levels = f.get_var()
		cfg.wall_levels = f.get_var()
		cfg.quarry_levels = f.get_var()
		cfg.brick_quanity = f.get_var()
		cfg.magic_levels = f.get_var()
		cfg.gem_quanity = f.get_var()
		cfg.dungeon_levels = f.get_var()
		cfg.recruit_quianity = f.get_var()
		# PLAY CONDITIONS
		cfg.auto_bricks = f.get_var()
		cfg.auto_gems = f.get_var()
		cfg.auto_recruits = f.get_var()
		cfg.cards_in_hand = f.get_var()
		cfg.ai_type = f.get_var()
		# VICTORY CONDITIONS
		cfg.tower_victory = f.get_var()
		cfg.resource_victory = f.get_var()
		# TAVERN PRESETS
		cfg.current_tavern = f.get_var()
		f.close()

func update_controls():
	pass

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
	cfg.intro_skip = button_pressed
