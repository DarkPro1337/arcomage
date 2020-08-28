extends Control

onready var exec = Expression.new()
var card_data = {}

var card_name
var card_description
var card_cost
var card_layout
var card_art
var card_func

func _ready():
	randomize()
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
	var random_card = card_data[card_data.keys()[randi() % card_data.size()]].id
	
	# CHANGING THE CARD VARS
	card_name = card_data.get(random_card).name
	card_art = str(card_data.get(random_card).pic).replace("../", "res://")
	card_description = card_data.get(random_card).description
	card_cost = card_data.get(random_card).cost
	card_layout = card_data.get(random_card).type
	card_func = card_data.get(random_card).func_text
	
	# CHANGING THE CARD LOOK
	$name.text = card_name
	$art.texture = load(card_art)
	$description.text = card_description
	$cost.text = str(card_cost)
	if card_layout == 0:
		$layout.texture = load("res://sprites/red_card_layout.png")
	elif card_layout == 1:
		$layout.texture = load("res://sprites/blue_card_layout.png")
	elif card_layout == 2:
		$layout.texture = load("res://sprites/green_card_layout.png")

func _on_card_input(event):
	if Input.is_action_just_released("ui_lmb"):
		exec.parse(card_func)
		exec.execute([card_func], self)
		if card_layout == 0:
			global.table.player_bricks -= card_cost
		elif card_layout == 1:
			global.table.player_gems -= card_cost
		elif card_layout == 2:
			global.table.player_recruits -= card_cost
		queue_free()

	if Input.is_action_just_released("ui_rmb"):
		if global.table.player_quarry < global.table.enemy_quarry:
			add_player_quarry(2)
		else:
			add_player_quarry(1)
		queue_free()

func _on_card_mouse_entered():
	$selector.show()

func _on_card_mouse_exited():
	$selector.hide()

func damage_player_tower(hp):
	global.table.player_tower_hp -= hp

func damage_player_wall(hp):
	global.table.player_wall_hp -= hp

func heal_player_tower(hp):
	global.table.player_tower_hp += hp

func heal_player_wall(hp):
	global.table.player_wall_hp += hp

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
	pass

func ifelse(cond, iftrue, iffalse):
	if cond:
		iftrue
		print("true")
	else:
		iffalse
		print("false")

func player_quarry():
	return global.table.player_quarry

func enemy_quarry():
	return global.table.enemy_quarry
