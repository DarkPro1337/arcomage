extends Control

onready var selector = get_node("selector")
onready var card_back = get_node("card_back")

var rng = RandomNumberGenerator.new()
var card_data = {}

var card_id
var card_name
var card_description
var card_cost
var card_layout
var card_art
var card_use
var card_not_discardable

var discardable = true
var usable = true
var bot_usable = true
var used = false

func _ready():
	rng.randomize() # RANDOMIZE THE SEED
	# DB LOAD
	var data_read = File.new()
	
	# CARDS DB LOCALE HANDLE
	if TranslationServer.get_locale() == "en":
		data_read.open("res://db/base.cdb", File.READ)
	elif TranslationServer.get_locale() == "ru":
		data_read.open("res://db/base_ru.cdb", File.READ)
	elif TranslationServer.get_locale() == "uk":
		data_read.open("res://db/base_uk.cdb", File.READ)
	elif TranslationServer.get_locale() == "uk":
		data_read.open("res://db/base_pl.cdb", File.READ)
	else:
		data_read.open("res://db/base.cdb", File.READ)
	
	var data_cdb = parse_json(data_read.get_as_text())
	data_read.close()
	for sheet in data_cdb["sheets"]:
		if sheet["name"] == "cards":
			for entry in sheet["lines"]:
				var new_entry = entry.duplicate()
				card_data[entry["id"]] = new_entry
	
	# PICK RANDOM CARD FROM DB
	var random_card = card_data[card_data.keys()[rng.randi_range(0, card_data.size() - 1)]].id
	
	# CHANGING THE CARD VARS
	card_id = card_data.get(random_card).id
	card_name = card_data.get(random_card).name
	card_art = str(card_data.get(random_card).pic).replace("../", "res://")
	card_description = card_data.get(random_card).description
	card_cost = card_data.get(random_card).cost
	card_layout = card_data.get(random_card).type
	card_use = card_data.get(random_card).use
	card_not_discardable = card_data.get(random_card).not_discardable
	
	# CHANGING THE CARD LOOK
	$name.text = card_name
	$art.texture = load(card_art)
	$description.text = card_description
	$cost.text = str(card_cost)
	
	set_name(card_id)
	
	if card_not_discardable == true:
		discardable = false
	
	if card_layout == 0:
		$layout.texture = load("res://sprites/red_card_layout_alt.png")
	elif card_layout == 1:
		$layout.texture = load("res://sprites/blue_card_layout_alt.png")
	elif card_layout == 2:
		$layout.texture = load("res://sprites/green_card_layout_alt.png")

# DISABLING CARDS ON RUNTIME
func _physics_process(delta):
	if get_parent().name == "graveyard":
		print("true")
	
	if is_in_group("player_card"):
		if card_layout == 0 and player_bricks() < card_cost:
			usable = false
			set_modulate(Color(0.5, 0.5, 0.5))
			mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		elif card_layout == 1 and player_gems() < card_cost:
			usable = false
			set_modulate(Color(0.5, 0.5, 0.5))
			mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		elif card_layout == 2 and player_recruits() < card_cost:
			usable = false
			set_modulate(Color(0.5, 0.5, 0.5))
			mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		else:
			usable = true
			set_modulate(Color(1, 1, 1))
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if used == true:
			set_modulate(Color(1, 1, 1))
			selector.hide()
	
	if is_in_group("enemy_card"):
		if card_layout == 0 and enemy_bricks() < card_cost:
			bot_usable = false
		elif card_layout == 1 and enemy_gems() < card_cost:
			bot_usable = false
		elif card_layout == 2 and enemy_recruits() < card_cost:
			bot_usable = false
		else:
			bot_usable = true

# PLAYER CARD USING
func _on_card_input(event):
	if global.table.player_discarding == true and (Input.is_action_just_pressed("ui_lmb") or Input.is_action_just_pressed("ui_rmb")):
		if discardable == true and not used == true and is_in_group("player_card"): 
			AudioStreamManager.play("res://sounds/deal.ogg")
			$discarded.show()
			global.table.remove_card(name)
			global.table.draw_card_label.hide()
			global.table.player_discarding = false
	
	if Input.is_action_just_pressed("ui_lmb"):
		if usable == true and not used == true and is_in_group("player_card"):
			if is_in_group("player_card"):
				print_time("PLAYER 1 USED CARD " + name)
			else:
				print_time("ERROR: CARD GROUP MISSED")
			AudioStreamManager.play("res://sounds/deal.ogg")
			card_func(card_id)
			card_charge()
			global.table.use_card(name)

	if Input.is_action_just_pressed("ui_rmb"):
		if discardable == true and not used == true and is_in_group("player_card"): 
			AudioStreamManager.play("res://sounds/deal.ogg")
			$discarded.show()
			global.table.remove_card(name)


# CARD SELECTOR
func _on_card_mouse_entered():
	if usable == true and is_in_group("player_card"):
		selector.self_modulate = Color(1, 1, 1)
		selector.show()
	elif usable == false and is_in_group("player_card"):
		selector.self_modulate = Color(1, 0, 0)
		selector.show()
	if used == true and is_in_group("player_card"):
		selector.hide()

func _on_card_mouse_exited():
	if usable == true and is_in_group("player_card"):
		selector.modulate = Color(1, 1, 1)
		selector.hide()
	elif usable == false and is_in_group("player_card"):
		selector.modulate = Color(1, 0, 0)
		selector.hide()
	if used == true and is_in_group("player_card"):
		selector.hide()

# CHARGE RESOURCES FROM PLAYER
func card_charge():
	if card_layout == 0:
		global.table.player_bricks -= card_cost
		if global.table.player_bricks < 0: global.table.player_bricks = 0
	elif card_layout == 1:
		global.table.player_gems -= card_cost
		if global.table.player_gems < 0: global.table.player_gems = 0
	elif card_layout == 2:
		global.table.player_recruits -= card_cost
		if global.table.player_recruits < 0: global.table.player_recruits = 0

# CHARGE RESOURCES FROM BOT
func bot_card_charge():
	if card_layout == 0:
		global.table.enemy_bricks -= card_cost
		if global.table.enemy_bricks < 0: global.table.enemy_bricks = 0
	elif card_layout == 1:
		global.table.enemy_gems -= card_cost
		if global.table.enemy_gems < 0: global.table.enemy_gems = 0
	elif card_layout == 2:
		global.table.enemy_recruits -= card_cost
		if global.table.enemy_recruits < 0: global.table.enemy_recruits = 0

# BOT CARD USING
func bot_card_use():
	if is_in_group("enemy_card"):
		print_time("PLAYER 2 USED CARD " + name)
	else:
		print_time("ERROR: CARD GROUP MISSED")
	AudioStreamManager.play("res://sounds/deal.ogg")
	card_func(card_id)
	bot_card_charge()
	global.table.bot_use_card(name)

func bot_card_remove():
	if is_in_group("enemy_card"):
		print_time("PLAYER 2 USED CARD " + name)
	else:
		print_time("ERROR: CARD GROUP MISSED")
	AudioStreamManager.play("res://sounds/deal.ogg")
	$discarded.show()
	global.table.bot_remove_card(name)

# CARD FUNCS
# TODO: MOVE TO SEPARATE SCRIPT
func card_func(id):
	match id:
		"brick_shortage": #0
			remove_player_bricks(8)
			remove_enemy_bricks(8)
		"lucky_cache": #1
			add_player_bricks(2)
			add_player_gems(2)
			play_again()
		"friendly_terrain": #2
			heal_player_wall(1)
			play_again()
		"miners": #3
			add_player_quarry(1)
		"mother_lode": #4
			if player_quarry() < enemy_quarry():
				add_player_quarry(2)
			else:
				add_player_quarry(1)
		"dwarven_miners": #5
			heal_player_wall(4)
			add_player_quarry(1)
		"work_overtime": #6
			heal_player_wall(5)
			remove_player_gems(6)
		"copping_the_tech": #7
			if player_quarry() < enemy_quarry():
				global.table.player_quarry = enemy_quarry()
		"basic_wall": #8
			heal_player_wall(3)
		"sturdy_wall": #9
			heal_player_wall(4)
		"innovations": #10
			add_player_quarry(1)
			add_enemy_quarry(1)
			add_player_gems(4)
		"foundations": #11
			if player_wall() == 0:
				heal_player_wall(6)
			else:
				heal_player_wall(3)
		"tremors": #12
			damage_player_wall(5)
			damage_enemy_wall(5)
			play_again()
		"secret_room": #13
			add_player_magic(1)
			play_again()
		"earthquake": #14
			remove_player_quarry(1)
			remove_enemy_quarry(1)
		"big_wall": #15
			heal_player_wall(6)
		"collapse": #16
			remove_enemy_quarry(1)
		"new_equipment": #17
			add_player_quarry(2)
		"strip_mine": #18
			remove_player_quarry(1)
			heal_player_wall(10)
			add_player_gems(5)
		"reinforced_wall": #19
			heal_player_wall(8)
		"porticulus": #20
			heal_player_wall(5)
			add_player_dungeons(1)
		"crystal_rocks": #21
			heal_player_wall(7)
			add_player_gems(7)
		"harmonic_ore": #22
			heal_player_wall(6)
			heal_player_tower(3)
		"mondo_wall": #23
			heal_player_wall(12)
		"focused_designs": #24
			heal_player_wall(8)
			heal_player_tower(5)
		"great_wall": #25
			heal_player_wall(15)
		"rock_launcher": #26
			heal_player_wall(6)
			damage_enemy(10)
		"dragons_heart": #27
			heal_player_wall(20)
			heal_player_tower(8)
		"forced_labor": #28
			heal_player_wall(9)
			remove_player_recruits(5)
		"rock_garden": #29
			heal_player_wall(1)
			heal_player_tower(1)
			add_player_recruits(2)
		"flood_water": #30
			if player_wall() < enemy_wall():
				remove_player_dungeons(1)
				damage_player_tower(2)
			elif player_wall() > enemy_wall():
				remove_enemy_dungeons(1)
				damage_enemy_tower(2)
		"barracks": #31
			add_player_recruits(6)
			heal_player_wall(6)
			if player_dungeon() < enemy_dungeon():
				add_player_dungeons(1)
		"battlements": #32
			heal_player_wall(7)
			damage_enemy(6)
		"shift": #33
			var player_wall = global.table.player_wall_hp
			var enemy_wall = global.table.enemy_wall_hp
			global.table.player_wall_hp = enemy_wall
			global.table.enemy_wall_hp = player_wall
		"quartz": #34
			heal_player_tower(1)
			play_again()
		"smoky_quartz": #35
			damage_enemy_tower(1)
			play_again()
		"amethyst": #36
			heal_player_tower(3)
		"spell_weavers": #37
			add_player_magic(1)
		"prism": #38
			draw_card(1)
			discard_card(1)
			play_again()
		"lodestone": #39
			heal_player_tower(3)
		"solar_flare": #40
			heal_player_tower(2)
			damage_enemy_tower(2)
		"crystal_matrix": #41
			add_player_magic(1)
			heal_player_tower(3)
			heal_enemy_tower(1)
		"gemstone_flaw": #42
			damage_enemy_tower(3)
		"ruby": #43
			heal_player_tower(5)
		"gem_spear": #44
			damage_enemy_tower(5)
		"power_burn": #45
			damage_enemy_tower(5)
			add_player_magic(2)
		"harmonic_vibe": #46
			add_player_magic(1)
			heal_player_tower(3)
			heal_player_wall(3)
		"parity": #47
			var highest
			if player_magic() >= enemy_magic():
				highest = player_magic()
			elif enemy_magic() >= player_magic():
				highest = enemy_magic()
			global.table.player_magic = highest
			global.table.enemy_magic = highest
		"emerald": #48
			heal_player_tower(8)
		"pearl_of_wisdom": #49
			heal_player_tower(5)
			add_player_magic(1)
		"shatterer": #50
			remove_player_magic(1)
			damage_enemy_tower(9)
		"crumblestone": #51
			heal_player_tower(5)
			remove_enemy_bricks(6)
		"sapphire": #52
			heal_player_tower(11)
		"discord": #53
			damage_player_tower(7)
			damage_enemy_tower(7)
			remove_player_magic(1)
			remove_enemy_magic(1)
		"fire_ruby": #54
			heal_player_tower(6)
			damage_enemy_tower(4) # TODO: add function to damage ALL ENEMIES (3-4 multiplayer)
		"quarrys_help": #55
			heal_player_tower(7)
			remove_player_bricks(10)
		"crystal_shield": #56
			heal_player_tower(8)
			heal_player_wall(3)
		"empathy_gem": #57
			heal_player_tower(8)
			add_player_dungeons(1)
		"diamond": #58
			heal_player_tower(15)
		"sanctuary": #59
			heal_player_tower(10)
			heal_player_wall(5)
			add_player_recruits(5)
		"lava_jewel": #60
			heal_player_tower(12)
			damage_enemy(6) # TODO: add function to damage ALL ENEMIES (3-4 multiplayer)
		"dragons_eye": #61
			heal_player_tower(20)
		"crystallize": #62
			heal_player_tower(11)
			damage_player_wall(6)
		"bag_of_baubles": #63
			if player_tower() < enemy_tower():
				heal_player_tower(2)
			else:
				heal_player_tower(1)
		"rainbow": #64
			heal_player_tower(1)
			heal_enemy_tower(1)
			add_player_gems(3)
		"apprentice": #65
			heal_player_tower(4)
			remove_player_recruits(3)
			damage_enemy_tower(2)
		"lightning_shard": #66
			if player_tower() > enemy_wall():
				damage_enemy_tower(8)
			else:
				damage_enemy(8)
		"phase_jewel": #67
			heal_player_tower(13)
			add_player_recruits(6)
			add_player_bricks(6)
		"mad_cow_disease": #68
			remove_player_recruits(6)
			remove_enemy_recruits(6)
		"faerie": #69
			damage_enemy(2)
			play_again()
		"moody_goblins": #70
			damage_enemy(4)
			remove_player_gems(3)
		"minotaur": #71
			add_player_dungeons(1)
		"elven_scout": #72
			draw_card(1)
			discard_card(1)
			play_again()
		"goblin_mob": #73
			damage_enemy(6)
			damage_player(3)
		"goblin_archers": #74
			damage_enemy_tower(3)
			damage_player(1)
		"shadow_faerie": #75
			damage_enemy_tower(2)
			play_again()
		"orc": #76
			damage_enemy(5)
		"dwarves": #77
			damage_enemy(4)
			heal_player_wall(3)
		"little_snakes": #78
			damage_enemy_tower(4)
		"troll_trainer": #79
			damage_enemy(2)
		"tower_gremlin": #80
			damage_enemy(2)
			heal_player_wall(4)
			heal_player_tower(2)
		"full_moon": #81
			add_player_dungeons(1)
			add_enemy_dungeons(1)
			add_player_recruits(3)
		"slasher": #82
			damage_enemy(6)
		"ogre": #83
			damage_enemy(7)
		"rabid_sheep": #84
			damage_enemy(6)
			remove_enemy_recruits(3)
		"imp": #85
			damage_enemy(6)
			remove_player_bricks(5)
			remove_enemy_bricks(5)
			remove_player_gems(5)
			remove_enemy_gems(5)
			remove_player_recruits(5)
			remove_enemy_recruits(5)
		"spizzer": #86
			if enemy_wall() == 0:
				damage_enemy(10)
			else:
				damage_enemy(6)
		"werewolf": #87
			damage_enemy(9)
		"corrosion_cloud": #88
			if enemy_wall() > 0:
				damage_enemy(10)
			else:
				damage_enemy(7)
		"unicorn": #89
			if player_magic() > enemy_magic():
				damage_enemy(12)
			else:
				damage_enemy(8)
		"elven_archers": #90
			if player_wall() > enemy_wall():
				damage_enemy_tower(6)
			else:
				damage_enemy(8)
		"succubus": #91
			damage_enemy_tower(5)
			remove_enemy_recruits(8)
		"rock_stompers": #92
			damage_enemy(8)
			remove_enemy_quarry(1)
		"thief": #93
			remove_enemy_gems(10)
			remove_enemy_bricks(5)
			add_player_gems(5)
			add_player_bricks(2)
		"stone_giant": #94
			damage_enemy(10)
			heal_player_wall(4)
		"vampire": #95
			damage_enemy(10)
			remove_enemy_recruits(5)
			remove_enemy_quarry(1)
		"dragon": #96
			damage_enemy(20)
			remove_enemy_gems(10)
			remove_enemy_dungeons(1)
		"spearman": #97
			if player_wall() > enemy_wall():
				damage_enemy(3)
			else:
				damage_enemy(2)
		"gnome": #98
			damage_enemy(3)
			add_player_gems(1)
		"berserker": #99
			damage_enemy(8)
			damage_player_tower(3)
		"warlord": #100
			damage_enemy(13)
			remove_player_gems(3)
		"pegasus_lancer": #101
			damage_enemy_tower(12)

func damage_player_tower(hp):
	if player_card():
		global.table.player_tower_hp -= hp
		if global.table.player_tower_hp < 0: global.table.player_tower_hp = 0
		global.table.emit_particles("damage_player_tower")
	elif enemy_card():
		global.table.enemy_tower_hp -= hp
		if global.table.enemy_tower_hp < 0: global.table.enemy_tower_hp = 0
		global.table.emit_particles("damage_enemy_tower")
	AudioStreamManager.play("res://sounds/damage.ogg")

func damage_player_wall(hp):
	if player_card():
		global.table.player_wall_hp -= hp
		if global.table.player_wall_hp < 0: global.table.player_wall_hp = 0
		global.table.emit_particles("damage_player_wall")
	elif enemy_card():
		global.table.enemy_wall_hp -= hp
		if global.table.enemy_wall_hp < 0: global.table.enemy_wall_hp = 0
		global.table.emit_particles("damage_enemy_wall")
	AudioStreamManager.play("res://sounds/damage.ogg")

func heal_player_tower(hp):
	if player_card():
		global.table.player_tower_hp += hp
		global.table.emit_particles("heal_player_tower")
	elif enemy_card():
		global.table.enemy_tower_hp += hp
		global.table.emit_particles("heal_enemy_tower")
	AudioStreamManager.play("res://sounds/up.ogg")

func heal_player_wall(hp):
	if player_card():
		global.table.player_wall_hp += hp
		global.table.emit_particles("heal_player_wall")
	elif enemy_card():
		global.table.enemy_wall_hp += hp
		global.table.emit_particles("heal_enemy_wall")
	AudioStreamManager.play("res://sounds/heal.ogg")

func damage_player(hp):
	if player_card():
		if global.table.player_wall_hp == 0:
			global.table.player_tower_hp -= hp
			if global.table.player_tower_hp < 0: global.table.player_tower_hp = 0
			global.table.emit_particles("damage_player_tower")
		else:
			var temp_wall_hp = global.table.enemy_wall_hp
			global.table.player_wall_hp -= hp
			if global.table.player_wall_hp < 0: 
				global.table.player_wall_hp = 0
				global.table.player_tower_hp -= temp_wall_hp - hp
				global.table.emit_particles("damage_player_tower")
			global.table.emit_particles("damage_player_wall")
	elif enemy_card():
		if global.table.enemy_wall_hp == 0:
			global.table.enemy_tower_hp -= hp
			if global.table.enemy_tower_hp < 0: global.table.enemy_tower_hp = 0
			global.table.emit_particles("damage_enemy_tower")
		else:
			var temp_wall_hp = global.table.enemy_wall_hp
			global.table.enemy_wall_hp -= hp
			if global.table.enemy_wall_hp < 0: 
				global.table.enemy_wall_hp = 0
				global.table.enemy_tower_hp -= temp_wall_hp - hp
				global.table.emit_particles("damage_enemy_tower")
			global.table.emit_particles("damage_enemy_wall")
	AudioStreamManager.play("res://sounds/damage.ogg")

func damage_enemy(hp):
	if player_card():
		if global.table.enemy_wall_hp == 0:
			global.table.enemy_tower_hp -= hp
			if global.table.enemy_tower_hp < 0: global.table.enemy_tower_hp = 0
			global.table.emit_particles("damage_enemy_tower")
		else:
			var temp_wall_hp = global.table.enemy_wall_hp
			global.table.enemy_wall_hp -= hp
			if global.table.enemy_wall_hp < 0: 
				global.table.enemy_wall_hp = 0
				global.table.enemy_tower_hp -= temp_wall_hp - hp
				global.table.emit_particles("damage_enemy_tower")
			global.table.emit_particles("damage_enemy_wall")
	elif enemy_card():
		if global.table.player_wall_hp == 0:
			global.table.player_tower_hp -= hp
			if global.table.player_tower_hp < 0: global.table.player_tower_hp = 0
			global.table.emit_particles("damage_player_tower")
		else:
			var temp_wall_hp = global.table.player_wall_hp
			global.table.player_wall_hp -= hp
			if global.table.player_wall_hp < 0: 
				global.table.player_wall_hp = 0
				global.table.player_tower_hp -= temp_wall_hp - hp
				global.table.emit_particles("damage_player_tower")
			global.table.emit_particles("damage_player_wall")
	AudioStreamManager.play("res://sounds/damage.ogg")

func add_player_quarry(num):
	if player_card():
		global.table.player_quarry += num
		global.table.emit_particles("add_player_quarry")
	elif enemy_card():
		global.table.enemy_quarry += num
		global.table.emit_particles("add_enemy_quarry")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_player_bricks(num):
	if player_card():
		global.table.player_bricks += num
		global.table.emit_particles("add_player_bricks")
	elif enemy_card():
		global.table.enemy_bricks += num
		global.table.emit_particles("add_enemy_bricks")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_player_magic(num):
	if player_card():
		global.table.player_magic += num
		global.table.emit_particles("add_player_magic")
	elif enemy_card():
		global.table.enemy_magic += num
		global.table.emit_particles("add_enemy_magic")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_player_gems(num):
	if player_card():
		global.table.player_gems += num
		global.table.emit_particles("add_player_gems")
	elif enemy_card():
		global.table.enemy_gems += num
		global.table.emit_particles("add_enemy_gems")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_player_dungeons(num):
	if player_card():
		global.table.player_dungeon += num
		global.table.emit_particles("add_player_dungeons")
	elif enemy_card():
		global.table.enemy_dungeon += num
		global.table.emit_particles("add_enemy_dungeons")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_player_recruits(num):
	if player_card():
		global.table.player_recruits += num
		global.table.emit_particles("add_player_recruits")
	elif enemy_card():
		global.table.enemy_recruits += num
		global.table.emit_particles("add_enemy_recruits")
	AudioStreamManager.play("res://sounds/launch.ogg")

func remove_player_quarry(num):
	if player_card():
		global.table.player_quarry -= num
		if global.table.player_quarry < 0: global.table.player_quarry = 0
		global.table.emit_particles("remove_player_quarry")
	elif enemy_card():
		global.table.enemy_quarry -= num
		if global.table.enemy_quarry < 0: global.table.enemy_quarry = 0
		global.table.emit_particles("remove_enemy_bricks")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_player_bricks(num):
	if player_card():
		global.table.player_bricks -= num
		if global.table.player_bricks < 0: global.table.player_bricks = 0
		global.table.emit_particles("remove_player_bricks")
	elif enemy_card():
		global.table.enemy_bricks -= num
		if global.table.enemy_bricks < 0: global.table.enemy_bricks = 0
		global.table.emit_particles("remove_enemy_bricks")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_player_magic(num):
	if player_card():
		global.table.player_magic -= num
		if global.table.player_magic < 0: global.table.player_magic = 0
		global.table.emit_particles("remove_player_gems")
	elif enemy_card():
		global.table.enemy_magic -= num
		if global.table.enemy_magic < 0: global.table.enemy_magic = 0
		global.table.emit_particles("remove_enemy_gems")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_player_gems(num):
	if player_card():
		global.table.player_gems -= num
		if global.table.player_gems < 0: global.table.player_gems = 0
		global.table.emit_particles("remove_player_gems")
	elif enemy_card():
		global.table.enemy_gems -= num
		if global.table.enemy_gems < 0: global.table.enemy_gems = 0
		global.table.emit_particles("remove_enemy_gems")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_player_dungeons(num):
	if player_card():
		global.table.player_dungeon -= num
		if global.table.player_dungeon < 0: global.table.player_dungeon = 0
		global.table.emit_particles("remove_player_recruits")
	elif enemy_card():
		global.table.enemy_dungeon -= num
		if global.table.enemy_dungeon < 0: global.table.enemy_dungeon = 0
		global.table.emit_particles("remove_enemy_recruits")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_player_recruits(num):
	if player_card():
		global.table.player_recruits -= num
		if global.table.player_recruits < 0: global.table.player_recruits = 0
		global.table.emit_particles("remove_player_recruits")
	elif enemy_card():
		global.table.enemy_recruits -= num
		if global.table.enemy_recruits < 0: global.table.enemy_recruits = 0
		global.table.emit_particles("remove_enemy_recruits")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func damage_enemy_tower(hp):
	if player_card():
		global.table.enemy_tower_hp -= hp
		if global.table.enemy_tower_hp < 0: global.table.enemy_tower_hp = 0
		global.table.emit_particles("damage_enemy_tower")
	elif enemy_card():
		global.table.player_tower_hp -= hp
		if global.table.player_tower_hp < 0: global.table.player_tower_hp = 0
		global.table.emit_particles("damage_player_tower")
	AudioStreamManager.play("res://sounds/damage.ogg")

func damage_enemy_wall(hp):
	if player_card():
		global.table.enemy_wall_hp -= hp
		if global.table.enemy_wall_hp < 0: global.table.enemy_wall_hp = 0
		global.table.emit_particles("damage_enemy_wall")
	elif enemy_card():
		global.table.player_wall_hp -= hp
		if global.table.player_wall_hp < 0: global.table.player_wall_hp = 0
		global.table.emit_particles("damage_player_wall")
	AudioStreamManager.play("res://sounds/damage.ogg")

func heal_enemy_tower(hp):
	if player_card():
		global.table.enemy_tower_hp += hp
		global.table.emit_particles("heal_enemy_tower")
	elif enemy_card():
		global.table.player_tower_hp += hp
		global.table.emit_particles("heal_player_tower")
	AudioStreamManager.play("res://sounds/up.ogg")

func heal_enemy_wall(hp):
	if player_card():
		global.table.enemy_wall_hp += hp
		global.table.emit_particles("heal_enemy_wall")
	elif enemy_card():
		global.table.player_wall_hp += hp
		global.table.emit_particles("heal_player_wall")
	AudioStreamManager.play("res://sounds/heal.ogg")

func add_enemy_quarry(num):
	if player_card():
		global.table.enemy_quarry += num
		global.table.emit_particles("add_enemy_quarry")
	elif enemy_card():
		global.table.player_quarry += num
		global.table.emit_particles("add_player_quarry")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_enemy_bricks(num):
	if player_card():
		global.table.enemy_bricks += num
		global.table.emit_particles("add_enemy_bricks")
	elif enemy_card():
		global.table.player_bricks += num
		global.table.emit_particles("add_player_bricks")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_enemy_magic(num):
	if player_card():
		global.table.enemy_magic += num
		global.table.emit_particles("add_enemy_magic")
	elif enemy_card():
		global.table.player_magic += num
		global.table.emit_particles("add_player_magic")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_enemy_gems(num):
	if player_card():
		global.table.enemy_gems += num
		global.table.emit_particles("add_enemy_gems")
	elif enemy_card():
		global.table.player_gems += num
		global.table.emit_particles("add_player_gems")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_enemy_dungeons(num):
	if player_card():
		global.table.enemy_dungeon += num
		global.table.emit_particles("add_enemy_dungeons")
	elif enemy_card():
		global.table.player_dungeon += num
		global.table.emit_particles("add_player_dungeons")
	AudioStreamManager.play("res://sounds/launch.ogg")

func add_enemy_recruits(num):
	if player_card():
		global.table.enemy_recruits += num
		global.table.emit_particles("add_enemy_recruits")
	elif enemy_card():
		global.table.player_recruits += num
		global.table.emit_particles("add_player_recruits")
	AudioStreamManager.play("res://sounds/launch.ogg")

func remove_enemy_quarry(num):
	if player_card():
		global.table.enemy_quarry -= num
		if global.table.enemy_quarry < 0: global.table.enemy_quarry = 0
		global.table.emit_particles("remove_enemy_bricks")
	elif enemy_card():
		global.table.player_quarry -= num
		if global.table.player_quarry < 0: global.table.player_quarry = 0
		global.table.emit_particles("remove_player_quarry")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_enemy_bricks(num):
	if player_card():
		global.table.enemy_bricks -= num
		if global.table.enemy_bricks < 0: global.table.enemy_bricks = 0
		global.table.emit_particles("remove_enemy_bricks")
	elif enemy_card():
		global.table.player_bricks -= num
		if global.table.player_bricks < 0: global.table.player_bricks = 0
		global.table.emit_particles("remove_player_bricks")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_enemy_magic(num):
	if player_card():
		global.table.enemy_magic -= num
		if global.table.enemy_magic < 0: global.table.enemy_magic = 0
		global.table.emit_particles("remove_enemy_gems")
	elif enemy_card():
		global.table.player_magic -= num
		if global.table.player_magic < 0: global.table.player_magic = 0
		global.table.emit_particles("remove_player_gems")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_enemy_gems(num):
	if player_card():
		global.table.enemy_gems -= num
		if global.table.enemy_gems < 0: global.table.enemy_gems = 0
		global.table.emit_particles("remove_enemy_gems")
	elif enemy_card():
		global.table.player_gems -= num
		if global.table.player_gems < 0: global.table.player_gems = 0
		global.table.emit_particles("remove_player_gems")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_enemy_dungeons(num):
	if player_card():
		global.table.enemy_dungeon -= num
		if global.table.enemy_dungeon < 0: global.table.enemy_dungeon = 0
		global.table.emit_particles("remove_enemy_recruits")
	elif enemy_card():
		global.table.player_dungeon -= num
		if global.table.player_dungeon < 0: global.table.player_dungeon = 0
		global.table.emit_particles("remove_player_recruits")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func remove_enemy_recruits(num):
	if player_card():
		global.table.enemy_recruits -= num
		if global.table.enemy_recruits < 0: global.table.enemy_recruits = 0
		global.table.emit_particles("remove_enemy_recruits")
	elif enemy_card():
		global.table.player_recruits -= num
		if global.table.player_recruits < 0: global.table.player_recruits = 0
		global.table.emit_particles("remove_player_recruits")
	AudioStreamManager.play("res://sounds/quarry_down.ogg")

func play_again():
	if player_card():
		global.table.player_play_again = true
	elif enemy_card():
		global.table.enemy_play_again = true

func draw_card(num):
	if player_card():
		global.table.player_draw_card = true
	if enemy_card():
		global.table.enemy_draw_card = true

func discard_card(num):
	if player_card():
		global.table.player_discarding = true
	if enemy_card():
		global.table.enemy_discarding = true

func player_quarry():
	if player_card():
		return global.table.player_quarry
	elif enemy_card():
		return global.table.enemy_quarry

func player_bricks():
	if player_card():
		return global.table.player_bricks
	elif enemy_card():
		return global.table.enemy_bricks

func player_magic():
	if player_card():
		return global.table.player_magic
	elif enemy_card():
		return global.table.player_magic

func player_gems():
	if player_card():
		return global.table.player_gems
	elif enemy_card():
		return global.table.player_gems

func player_dungeon():
	if player_card():
		return global.table.player_dungeon
	elif enemy_card():
		return global.table.enemy_dungeon

func player_recruits():
	if player_card():
		return global.table.player_recruits
	elif enemy_card():
		return global.table.enemy_recruits

func enemy_quarry():
	if player_card():
		return global.table.enemy_quarry
	elif enemy_card():
		return global.table.player_quarry

func enemy_bricks():
	if player_card():
		return global.table.enemy_bricks
	elif enemy_card():
		return global.table.player_bricks

func enemy_magic():
	if player_card():
		return global.table.enemy_magic
	elif enemy_card():
		return global.table.player_magic

func enemy_gems():
	if player_card():
		return global.table.enemy_gems
	elif enemy_card():
		return global.table.player_gems

func enemy_dungeon():
	if player_card():
		return global.table.enemy_dungeon
	elif enemy_card():
		return global.table.player_dungeon

func enemy_recruits():
	if player_card():
		return global.table.enemy_recruits
	elif enemy_card():
		return global.table.player_recruits

func player_tower():
	if player_card():
		return global.table.player_tower_hp
	elif enemy_card():
		return global.table.enemy_tower_hp

func player_wall():
	if player_card():
		return global.table.player_wall_hp
	elif enemy_card():
		return global.table.enemy_wall_hp

func enemy_tower():
	if player_card():
		return global.table.enemy_tower_hp
	elif enemy_card():
		return global.table.player_tower_hp

func enemy_wall():
	if player_card():
		return global.table.enemy_wall_hp
	elif enemy_card():
		return global.table.player_wall_hp

func player_card():
	return is_in_group("player_card")

func enemy_card():
	return is_in_group("enemy_card")

func print_time(message: String):
	print("[" + str(global.table.str_elapsed) + "] " + str(message))
