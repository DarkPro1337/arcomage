extends Control

var card = preload("res://scenes/card.tscn")
var player_name = "DarkPro1337"
var enemy_name = "COMPUTER"

# DEFAULT TOWER AND WALL HP
var player_tower_hp = 50
var player_wall_hp = 50

var enemy_tower_hp = 50
var enemy_wall_hp = 50

# DEFAULT RESOURCES
var player_quarry = 5
var player_bricks = 20
var player_magic = 3
var player_gems = 10
var player_dungeon = 5
var player_recruits = 20

var enemy_quarry = 5
var enemy_bricks = 20
var enemy_magic = 3
var enemy_gems = 10
var enemy_dungeon = 5
var enemy_recruits = 20

func _input(event):
	if Input.is_action_just_pressed("ui_reset"):
		get_tree().reload_current_scene()

func _ready():
	global.table = self
	$player_panel/player_name.text = player_name
	$enemy_panel/enemy_name.text = enemy_name

func _physics_process(delta):
	update_stat_panels()
	while get_tree().get_nodes_in_group("cards").size() != 6:
		var card_inst = card.instance()
		$deck.add_child(card_inst)

func update_stat_panels():
	# PLAYER STATS
	$player_bricks_panel/per_turn.text = str(player_quarry)
	$player_bricks_panel/total.text = str(player_bricks)
	$player_gems_panel/per_turn.text = str(player_magic)
	$player_gems_panel/total.text = str(player_gems)
	$player_recruits_panel/per_turn.text = str(player_dungeon)
	$player_recruits_panel/total.text = str(player_recruits)
	# ENEMY STATS
	$enemy_bricks_panel/per_turn.text = str(enemy_quarry)
	$enemy_bricks_panel/total.text = str(enemy_bricks)
	$enemy_gems_panel/per_turn.text = str(enemy_magic)
	$enemy_gems_panel/total.text = str(enemy_gems)
	$enemy_recruits_panel/per_turn.text = str(enemy_dungeon)
	$enemy_recruits_panel/total.text = str(enemy_recruits)
	# PLAYER TOWER AND WALL
	$player_tower_panel/tower_hp.text = str(player_tower_hp)
	$player_wall_panel/wall_hp.text = str(player_wall_hp)
	$player_tower.set_size(Vector2(45, player_tower_hp))
	$player_wall.set_size(Vector2(24, player_wall_hp))
	# ENEMY TOWER AND WALL
	$enemy_tower_panel/tower_hp.text = str(enemy_tower_hp)
	$enemy_wall_panel/wall_hp.text = str(enemy_wall_hp)
	$enemy_tower.set_size(Vector2(45, enemy_tower_hp))
	$enemy_wall.set_size(Vector2(24, enemy_wall_hp))
