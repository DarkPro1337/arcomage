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

func _ready():
	$player_panel/player_name.text = player_name
	$enemy_panel/enemy_name.text = enemy_name
	for i in 6:
		var card_inst = card.instance()
		$deck.add_child(card_inst)
