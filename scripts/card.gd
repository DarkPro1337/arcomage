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

var discardable = true
var usable = true
var used = false

func _ready():
	rng.randomize() # RANDOMIZE THE SEED
	# DB LOAD
	var data_read = File.new()
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
	set_name(card_id)
	
	# CHANGING THE CARD LOOK
	$name.text = card_name
	$art.texture = load(card_art)
	$description.text = card_description
	$cost.text = str(card_cost)
	if card_layout == 0:
		$layout.texture = load("res://sprites/red_card_layout_alt.png")
	elif card_layout == 1:
		$layout.texture = load("res://sprites/blue_card_layout_alt.png")
	elif card_layout == 2:
		$layout.texture = load("res://sprites/green_card_layout_alt.png")

func _physics_process(delta):
	if is_in_group("player_card"):
		if card_layout == 0 and player_bricks() < card_cost:
			usable = false
			set_modulate(Color(0.5, 0.5, 0.5))
		elif card_layout == 1 and player_gems() < card_cost:
			usable = false
			set_modulate(Color(0.5, 0.5, 0.5))
		elif card_layout == 2 and player_recruits() < card_cost:
			usable = false
			set_modulate(Color(0.5, 0.5, 0.5))
		else:
			usable = true
			set_modulate(Color(1, 1, 1))
		
		if used == true:
			set_modulate(Color(1, 1, 1))
			selector.hide()

func _on_card_input(event):
	if Input.is_action_just_pressed("ui_lmb"):
		if usable == true:
			card_func(card_id)
			card_charge()
			global.table.use_card(name)

	if Input.is_action_just_pressed("ui_rmb"):
		if discardable == true: 
			global.table.remove_card(name)

func _on_card_mouse_entered():
	if usable == true:
		selector.self_modulate = Color(1, 1, 1)
		selector.show()
	elif usable == false:
		selector.self_modulate = Color(1, 0, 0)
		selector.show()

func _on_card_mouse_exited():
	if usable == true:
		selector.modulate = Color(1, 1, 1)
		selector.hide()
	elif usable == false:
		selector.modulate = Color(1, 0, 0)
		selector.hide()

func card_charge():
	if card_layout == 0:
		global.table.player_bricks -= card_cost
	elif card_layout == 1:
		global.table.player_gems -= card_cost
	elif card_layout == 2:
		global.table.player_recruits -= card_cost

func bot_card_charge():
	if card_layout == 0:
		global.table.enemy_bricks -= card_cost
	elif card_layout == 1:
		global.table.enemy_gems -= card_cost
	elif card_layout == 2:
		global.table.enemy_recruits -= card_cost

func bot_card_use():
	card_func(card_id)
	bot_card_charge()
	global.table.bot_use_card(name)

func card_func(id):
	match id:
		"brick_shortage":
			remove_player_bricks(8)
			remove_enemy_bricks(8)
		"lucky_cache":
			add_player_bricks(2)
			add_player_gems(2)
			play_again()
		"friendly_terrain":
			heal_player_wall(1)
			play_again()
		"miners":
			add_player_quarry(1)
		"mother_lode":
			if player_quarry() < enemy_quarry():
				add_player_quarry(2)
			else:
				add_player_quarry(1)
		"dwarven_miners":
			heal_player_wall(4)
			add_player_quarry(1)
		"work_overtime":
			heal_player_wall(5)
			remove_player_gems(6)
		"copping_the_tech":
			if player_quarry() < enemy_quarry():
				global.table.player_quarry = enemy_quarry()
		"basic_wall":
			heal_player_wall(3)
		"sturdy_wall":
			heal_player_wall(4)
		"innovations":
			add_player_quarry(1)
			add_enemy_quarry(1)
			add_player_gems(4)
		"foundations":
			if player_wall() == 0:
				heal_player_wall(6)
			else:
				heal_player_wall(3)
		"tremors":
			damage_player_wall(5)
			damage_enemy_wall(5)
			play_again()
		"secret_room":
			add_player_magic(1)
			play_again()
		"earthquake":
			remove_player_quarry(1)
			remove_enemy_quarry(1)
		"big_wall":
			heal_player_wall(6)
		"collapse":
			remove_enemy_quarry(1)
		"new_equipment":
			add_player_quarry(2)
		"strip_mine":
			remove_player_quarry(1)
			heal_player_wall(10)
			add_player_gems(5)
		"reinforced_wall":
			heal_player_wall(8)
		"porticulus":
			heal_player_wall(5)
			add_player_dungeons(1)
		"crystal_rocks":
			heal_player_wall(7)
			add_player_gems(7)
		"harmonic_ore":
			heal_player_wall(6)
			heal_player_tower(3)
		"mondo_wall":
			heal_player_wall(12)
		"focused_designs":
			heal_player_wall(8)
			heal_player_tower(5)
		"great_wall":
			heal_player_wall(15)
		"rock_launcher":
			heal_player_wall(6)
			damage_enemy(10)
		"dragons_heart":
			heal_player_wall(20)
			heal_player_tower(8)
		"forced_labor":
			heal_player_wall(9)
			remove_player_recruits(5)
		"rock_garden":
			heal_player_wall(1)
			heal_player_tower(1)
			add_player_recruits(2)
		"flood_water":
			if player_wall() < enemy_wall():
				remove_player_dungeons(1)
				damage_player_tower(2)
			elif player_wall() > enemy_wall():
				remove_enemy_dungeons(1)
				damage_enemy_tower(2)
		"barracks":
			add_player_recruits(6)
			heal_player_wall(6)
			if player_dungeon() < enemy_dungeon():
				add_player_dungeons(1)
		"battlements":
			heal_player_wall(7)
			damage_enemy(6)
		"shift":
			var player_wall = global.table.player_wall_hp
			var enemy_wall = global.table.enemy_wall_hp
			global.table.player_wall_hp = enemy_wall
			global.table.enemy_wall_hp = player_wall
		"quartz":
			heal_player_tower(1)
			play_again()
		"smoky_quartz":
			damage_enemy(1)
			play_again()
		"amethyst":
			heal_player_tower(3)
		"spell_weavers":
			add_player_magic(1)
		"prism":
			draw_card(1)
			discard_card(1)
			play_again()
		"lodestone":
			heal_player_tower(3)
		"solar_flare":
			heal_player_tower(2)
			damage_enemy_tower(2)
		"crystal_matrix":
			add_player_magic(1)
			heal_player_tower(3)
			heal_enemy_tower(1)
		"gemstone_flaw":
			damage_enemy_tower(3)
		"ruby":
			heal_player_tower(5)
		"gem_spear":
			damage_enemy_tower(5)
		"power_burn":
			damage_enemy_tower(5)
			add_player_magic(2)
		"harmonic_vibe":
			add_player_magic(1)
			heal_player_tower(3)
			heal_player_wall(3)
		"parity":
			var highest
			if player_magic() >= enemy_magic():
				highest = player_magic()
			elif enemy_magic() >= player_magic():
				highest = enemy_magic()
			global.table.player_magic = highest
			global.table.enemy_magic = highest
		"emerald":
			heal_player_tower(8)
		"pearl_of_wisdom":
			heal_player_tower(5)
			add_player_magic(1)
		"shatterer":
			remove_player_magic(1)
			damage_enemy_tower(9)
		"crumblestone":
			heal_player_tower(5)
			remove_enemy_bricks(6)
		"sapphire":
			heal_player_tower(11)
		"discord":
			damage_player_tower(7)
			damage_enemy_tower(7)
			remove_player_magic(1)
			remove_enemy_magic(1)
		"fire_ruby":
			heal_player_tower(6)
			damage_enemy_tower(4) # TODO: add function to damage ALL ENEMIES (3-4 multiplayer)
		"quarrys_help":
			heal_player_tower(7)
			remove_player_bricks(10)
		"crystal_shield":
			heal_player_tower(8)
			heal_player_wall(3)
		"empathy_gem":
			heal_player_tower(8)
			add_player_dungeons(1)
		"diamond":
			heal_player_tower(15)
		"sanctuary":
			heal_player_tower(10)
			heal_player_wall(5)
			add_player_recruits(5)
		"lava_jewel":
			heal_player_tower(12)
			damage_enemy(6) # TODO: add function to damage ALL ENEMIES (3-4 multiplayer)
		"dragons_eye":
			heal_player_tower(20)
		"crystallize":
			heal_player_tower(11)
			damage_player_wall(6)
		"bag_of_baubles":
			if player_tower() < enemy_tower():
				heal_player_tower(2)
			else:
				heal_player_tower(1)
		"rainbow":
			heal_player_tower(1)
			heal_enemy_tower(1)
			add_player_gems(3)
		"apprentice":
			heal_player_tower(4)
			remove_player_recruits(3)
			damage_enemy_tower(2)
		"phase_jewel":
			heal_player_tower(13)
			add_player_recruits(6)
			add_player_bricks(6)
		"mad_cow_disease":
			remove_player_recruits(6)
			remove_enemy_recruits(6)
		"faerie":
			damage_enemy(2)
			play_again()
		"moody_goblins":
			damage_enemy(4)
			remove_player_gems(3)
		"minotaur":
			add_player_dungeons(1)
		"elven_scout":
			draw_card(1)
			discard_card(1)
			play_again()
		"goblin_mob":
			damage_enemy(6)
			damage_player(3)
		"goblin_archers":
			damage_enemy_tower(3)
			damage_player(1)
		"shadow_faerie":
			damage_enemy_tower(2)
			play_again()
		"orc":
			damage_enemy(5)
		"dwarves":
			damage_enemy(4)
			heal_player_wall(3)
		"little_snakes":
			damage_enemy_tower(4)
		"troll_trainer":
			damage_enemy(2)
		"tower_gremlin":
			damage_enemy(2)
			heal_player_wall(4)
			heal_player_tower(2)
		"full_moon":
			add_player_dungeons(1)
			add_enemy_dungeons(1)
			add_player_recruits(3)
		"slasher":
			damage_enemy(6)
		"ogre":
			damage_enemy(7)
		"rabid_sheep":
			damage_enemy(6)
			remove_enemy_recruits(3)
		"imp":
			damage_enemy(6)
			remove_player_bricks(5)
			remove_enemy_bricks(5)
			remove_player_gems(5)
			remove_enemy_gems(5)
			remove_player_recruits(5)
			remove_enemy_recruits(5)
		"spizzer":
			if enemy_wall() == 0:
				damage_enemy(10)
			else:
				damage_enemy(6)
		"werewolf":
			damage_enemy(9)
		"corrosion_cloud":
			if enemy_wall() > 0:
				damage_enemy(10)
			else:
				damage_enemy(7)
		"unicorn":
			if player_magic() > enemy_magic():
				damage_enemy(12)
			else:
				damage_enemy(8)
		"elven_archers":
			if player_wall() > enemy_wall():
				damage_enemy_tower(6)
			else:
				damage_enemy(8)
		"succubus":
			damage_enemy_tower(5)
			remove_enemy_recruits(8)
		"rock_stompers":
			damage_enemy(8)
			remove_enemy_quarry(1)
		"thief":
			remove_enemy_gems(10)
			remove_enemy_bricks(5)
			add_player_gems(5)
			add_player_bricks(2)
		"stone_giant":
			damage_enemy(10)
			heal_player_wall(4)
		"vampire":
			damage_enemy(10)
			remove_enemy_recruits(5)
			remove_enemy_quarry(1)
		"dragon":
			damage_enemy(20)
			remove_enemy_gems(10)
			remove_enemy_dungeons(1)
		"spearman":
			if player_wall() > enemy_wall():
				damage_enemy(3)
			else:
				damage_enemy(2)
		"gnome":
			damage_enemy(3)
			add_player_gems(1)
		"berserker":
			damage_enemy(8)
			damage_player_tower(3)
		"warlord":
			damage_enemy(13)
			remove_player_gems(3)
		"pegasus_lancer":
			damage_enemy_tower(12)

func damage_player_tower(hp):
	global.table.player_tower_hp -= hp

func damage_player_wall(hp):
	global.table.player_wall_hp -= hp

func heal_player_tower(hp):
	global.table.player_tower_hp += hp

func heal_player_wall(hp):
	global.table.player_wall_hp += hp

func damage_player(hp):
	if global.table.player_wall_hp == 0:
		global.table.player_tower_hp -= hp
	else:
		global.table.player_wall_hp -= hp

func damage_enemy(hp):
	if global.table.enemy_wall_hp == 0:
		global.table.enemy_tower_hp -= hp
	else:
		global.table.enemy_wall_hp -= hp

func add_player_quarry(num):
	global.table.player_quarry += num

func add_player_bricks(num):
	global.table.player_bricks += num

func add_player_magic(num):
	global.table.player_magic += num

func add_player_gems(num):
	global.table.player_gems += num

func add_player_dungeons(num):
	global.table.player_dungeon += num

func add_player_recruits(num):
	global.table.player_recruits += num

func remove_player_quarry(num):
	global.table.player_quarry -= num

func remove_player_bricks(num):
	global.table.player_bricks -= num

func remove_player_magic(num):
	global.table.player_magic -= num

func remove_player_gems(num):
	global.table.player_gems -= num

func remove_player_dungeons(num):
	global.table.player_dungeon -= num

func remove_player_recruits(num):
	global.table.player_recruits -= num

func damage_enemy_tower(hp):
	global.table.enemy_tower_hp -= hp

func damage_enemy_wall(hp):
	global.table.enemy_wall_hp -= hp

func heal_enemy_tower(hp):
	global.table.enemy_tower_hp += hp

func heal_enemy_wall(hp):
	global.table.enemy_wall_hp += hp

func add_enemy_quarry(num):
	global.table.enemy_quarry += num

func add_enemy_bricks(num):
	global.table.enemy_bricks += num

func add_enemy_magic(num):
	global.table.enemy_magic += num

func add_enemy_gems(num):
	global.table.enemy_gems += num

func add_enemy_dungeons(num):
	global.table.enemy_dungeon += num

func add_enemy_recruits(num):
	global.table.enemy_recruits += num

func remove_enemy_quarry(num):
	global.table.enemy_quarry -= num

func remove_enemy_bricks(num):
	global.table.enemy_bricks -= num

func remove_enemy_magic(num):
	global.table.enemy_magic -= num

func remove_enemy_gems(num):
	global.table.enemy_gems -= num

func remove_enemy_dungeons(num):
	global.table.enemy_dungeon -= num

func remove_enemy_recruits(num):
	global.table.enemy_recruits -= num

func play_again():
	pass # TODO

func draw_card(num):
	pass # TODO

func discard_card(num):
	pass # TODO

func player_quarry():
	return global.table.player_quarry

func player_bricks():
	return global.table.player_bricks

func player_magic():
	return global.table.player_magic

func player_gems():
	return global.table.player_gems

func player_dungeon():
	return global.table.player_dungeon

func player_recruits():
	return global.table.player_recruits

func enemy_quarry():
	return global.table.enemy_quarry

func enemy_bricks():
	return global.table.enemy_bricks

func enemy_magic():
	return global.table.enemy_magic

func enemy_gems():
	return global.table.enemy_gems

func enemy_dungeon():
	return global.table.enemy_dungeon

func enemy_recruits():
	return global.table.enemy_recruits

func player_tower():
	return global.table.player_tower_hp

func player_wall():
	return global.table.player_wall_hp

func enemy_tower():
	return global.table.enemy_tower_hp

func enemy_wall():
	return global.table.enemy_wall_hp
