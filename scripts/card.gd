extends Control

var card_data = {}

var card_name
var card_description
var card_cost
var card_layout
var card_art

func _ready():
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
	if Input.is_action_pressed("ui_lmb"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("ui_rmb"):
		pass #TODO

func _on_card_mouse_entered():
	$selector.show()

func _on_card_mouse_exited():
	$selector.hide()

func damage_tower(hp):
	pass #TODO

func damage_wall(hp):
	pass #TODO

func heal_tower(hp):
	pass #TODO

func heal_wall(hp):
	pass #TODO

func add_quarry(num):
	pass #TODO

func add_bricks(num):
	pass #TODO

func add_magic(num):
	pass #TODO

func add_gems(num):
	pass #TODO

func add_dungeons(num):
	pass #TODO

func add_recruits(num):
	pass #TODO
