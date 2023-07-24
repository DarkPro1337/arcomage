class_name Table
extends Control

# RANDOMIZER INIT
var rng = RandomNumberGenerator.new()

# MISC OBJECT LINKS
@onready var particles = $particles
@onready var card_back = $graveyard/card_back
@onready var graveyard = $graveyard
@onready var draw_card_label = $draw_card_label
@onready var endgame_screen = $endgame
@onready var time_elapsed = $Time_Elapsed

# TABLE LINKS
@onready var player_deck = $player_deck
@onready var enemy_deck = $enemy_deck
@onready var ui_player_name = $player_panel/player_name
@onready var ui_enemy_name = $enemy_panel/enemy_name
@onready var deck_locker = $deck_locker

# PLAYER STATS PANEL LINKS
@onready var player_bricks_panel = $player_bricks_panel
@onready var player_bricks_per_panel = $player_bricks_panel/per_turn
@onready var player_bricks_total_panel = $player_bricks_panel/total
@onready var player_gems_panel = $player_gems_panel
@onready var player_gems_per_panel = $player_gems_panel/per_turn
@onready var player_gems_total_panel = $player_gems_panel/total
@onready var player_recruits_panel = $player_recruits_panel
@onready var player_recruits_per_panel = $player_recruits_panel/per_turn
@onready var player_recruits_total_panel = $player_recruits_panel/total
# ENEMY STATS PANEL LINKS
@onready var enemy_bricks_panel = $enemy_bricks_panel
@onready var enemy_bricks_per_panel = $enemy_bricks_panel/per_turn
@onready var enemy_bricks_total_panel = $enemy_bricks_panel/total
@onready var enemy_gems_panel = $enemy_gems_panel
@onready var enemy_gems_per_panel = $enemy_gems_panel/per_turn
@onready var enemy_gems_total_panel = $enemy_gems_panel/total
@onready var enemy_recruits_panel = $enemy_recruits_panel
@onready var enemy_recruits_per_panel = $enemy_recruits_panel/per_turn
@onready var enemy_recruits_total_panel = $enemy_recruits_panel/total
# PLAYER STATS PANEL ALTERNATIVE LINKS
@onready var player_bricks_panel_alt = $player_bricks_panel_alt
@onready var player_bricks_per_panel_alt = $player_bricks_panel_alt/per_turn
@onready var player_bricks_total_panel_alt = $player_bricks_panel_alt/total
@onready var player_gems_panel_alt = $player_gems_panel_alt
@onready var player_gems_per_panel_alt = $player_gems_panel_alt/per_turn
@onready var player_gems_total_panel_alt = $player_gems_panel_alt/total
@onready var player_recruits_panel_alt = $player_recruits_panel_alt
@onready var player_recruits_per_panel_alt = $player_recruits_panel_alt/per_turn
@onready var player_recruits_total_panel_alt = $player_recruits_panel_alt/total
# ENEMY STATS PANEL ALTERNATIVE LINKS
@onready var enemy_bricks_panel_alt = $enemy_bricks_panel_alt
@onready var enemy_bricks_per_panel_alt = $enemy_bricks_panel_alt/per_turn
@onready var enemy_bricks_total_panel_alt = $enemy_bricks_panel_alt/total
@onready var enemy_gems_panel_alt = $enemy_gems_panel_alt
@onready var enemy_gems_per_panel_alt = $enemy_gems_panel_alt/per_turn
@onready var enemy_gems_total_panel_alt = $enemy_gems_panel_alt/total
@onready var enemy_recruits_panel_alt = $enemy_recruits_panel_alt
@onready var enemy_recruits_per_panel_alt = $enemy_recruits_panel_alt/per_turn
@onready var enemy_recruits_total_panel_alt = $enemy_recruits_panel_alt/total
# UI LINKS
@onready var ingame_menu = $ingame_menu

# PLAYER NAMES
var player_name = cfg.nickname
var enemy_name = tr("COMPUTER")

enum players {red, blue} # TODO: Multiplayer enum for players UIDs
var turn # Represents which player's turn now.
var AI_ready = true # AI toggle, currently hardcoded.
var player_play_again = false # Should player play again instead of switching turn.
var enemy_play_again = false # Should enemy play again instead of switching turn.
var player_discarding = false # Should player discard a card instead of switching turn.
var enemy_discarding = false # Should enemy discard a card instead of switching turn.
var player_draw_card = false # Should player draw a card instead of switching turn.
var enemy_draw_card = false # Should enemy draw a card instead of switching turn.

# DEFAULT TOWER AND WALL HP
var player_tower_hp = cfg.tower_levels
var player_wall_hp = cfg.wall_levels

var enemy_tower_hp = cfg.tower_levels
var enemy_wall_hp = cfg.wall_levels

# DEFAULT RESOURCES
var player_quarry = cfg.quarry_levels
var player_bricks = cfg.brick_quantity
var player_magic = cfg.magic_levels
var player_gems = cfg.gem_quantity
var player_dungeon = cfg.dungeon_levels
var player_recruits = cfg.recruit_quantity

var enemy_quarry = cfg.quarry_levels
var enemy_bricks = cfg.brick_quantity
var enemy_magic = cfg.magic_levels
var enemy_gems = cfg.gem_quantity
var enemy_dungeon = cfg.dungeon_levels
var enemy_recruits = cfg.recruit_quantity

var time_start = 0 # From what value should timer start.
var time_now = 0 # Represents current timer value.
var elapsed = 0 # Represents elapsed time value.
var str_elapsed = "00:00" # Represents elapsed time string in 00:00 format.

signal graveyard_anim_ended # Signal that represents graveyard animation ended.
signal deck_anim_ended # Signal that represents table deck animation ended.

# For now - it's only placeholder for moving back to main menu.
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		ingame_menu.show()
		get_tree().paused = true

# Complete actions on start of current game.
func _ready():
	global.table = self # Declare global link to the current game table.
	rng.randomize() # Randomize timer.
	turn = rng.randi_range(0, players.size() - 1) # "Roll the dice", or in other word - randomize which player's first turn.
	add_resources(turn) # Add resources to the first player.
	locale_stat_panels() # Decide how should panels look like based on selected locale.
	ui_player_name.text = player_name # Insert current RED player nickname.
	ui_enemy_name.text = enemy_name # Insert current BLUE player nickname.
	
	# PLAYER START DECK GENERATION
	## Generates required ammount of cards to the player in a loop, which is declared by user config.
	## For multiplayer: Config priority to the host.
	while player_deck.get_child_count() != cfg.cards_in_hand:
		var card = load("res://scenes/card.tscn")
		var card_inst = card.instantiate() # Card instansing.
		card_inst.add_to_group("player_card") # Add card to player group for separating.
		player_deck.add_child(card_inst) # Add instance to the player deck.
		card_inst.usable = true # TODO: Should be reworked.
	
	# ENEMY START DECK GENERATION
	## Generates required ammount of cards to the enemy in a loop, which is declared by user config.
	## For multiplayer: Config priority to the host.
	while enemy_deck.get_child_count() != cfg.cards_in_hand:
		var card = load("res://scenes/card.tscn")
		var card_inst = card.instantiate() # Card instansing.
		card_inst.add_to_group("enemy_card") # Add card to enemy group for separating.
		enemy_deck.add_child(card_inst) # Add instance to the player deck.
		card_inst.card_back.show() # Hide BLUE card wih card back, in other words - "flip it". TODO: Should be reworked.
		card_inst.usable = false # Makes BLUE cards not usable for RED player. TODO: Should be reworked.

func _physics_process(delta):
	update_stat_panels() # Update stats panels call.
	# Always check which player should make it's turn.
	if turn == 0:
		# Toggle deck visablity.
		player_deck.show()
		enemy_deck.hide()
	elif turn == 1 and AI_ready == true:
		# Togble deck visablity.
		# Toggle AI.
		# TODO: Should be rewokred.
		AI_ready = false
		player_deck.hide()
		enemy_deck.show()
		
		# ARCOMAGE BOT v.0.3 (stable)
		# DON'T TRY TO UNDERSTAND THIS, LOL
		if cfg.ai_type == 0:
			var bot_atk_card_count = 0
			var bot_def_card_count = 0
			var bot_res_card_count = 0
			# GET CURRENT NUMBERS OF ATK, DEF AND RES CARDS IN DECK
			for i in enemy_deck.get_child_count():
				var card = enemy_deck.get_child(i)
				if card.card_use == 0: #atk
					bot_atk_card_count += 1
				elif card.card_use == 1: #def
					bot_def_card_count += 1
				elif card.card_use == 2: #res
					bot_res_card_count += 1
				print("ATK: " + str(bot_atk_card_count) + " DEF: " + str(bot_def_card_count) + " RES: " + str(bot_res_card_count))
			
			# Decide which card should be played or discarded based on current tower or wall HP and resources values.
			# Also it prints states for the log.
			for i in enemy_deck.get_child_count():
				var card = enemy_deck.get_child(i)
				if enemy_discarding == true and card.bot_usable == true:
					if card.card_use == 2: #res
						await get_tree().create_timer(1).timeout
						enemy_deck.get_node(card.name).bot_card_remove()
						print("BOT: REMOVING RESORCE CARD")
						enemy_discarding = false
						break
					else:
						var random_bot_card = enemy_deck.get_child(rng.randi_range(0, enemy_deck.get_child_count() - 1))
						await get_tree().create_timer(1).timeout
						enemy_deck.get_node(random_bot_card.name).bot_card_remove()
						print("BOT: NOT ENOUGH CARDS, DISCARD RANDOM CARD")
						break
				elif (enemy_tower_hp + enemy_wall_hp) >= (player_tower_hp + player_wall_hp) and bot_atk_card_count != 0 and card.bot_usable == true:
					if card.card_use == 0: #atk
						await get_tree().create_timer(1).timeout
						enemy_deck.get_node(card.name).bot_card_use()
						print("BOT: USING ATTACK CARD")
						break
				elif (enemy_tower_hp + enemy_wall_hp) <= (player_tower_hp + player_wall_hp) and bot_def_card_count != 0 and card.bot_usable == true:
					if card.card_use == 1: #def
						await get_tree().create_timer(1).timeout
						enemy_deck.get_node(card.name).bot_card_use()
						print("BOT: USING DEFENCE CARD")
						break
				elif (enemy_tower_hp + enemy_wall_hp) == (player_tower_hp + player_wall_hp) and bot_res_card_count != 0 and card.bot_usable == true:
					if card.card_use == 2: #res
						await get_tree().create_timer(1).timeout
						enemy_deck.get_node(card.name).bot_card_use()
						print("BOT: USING RESORCE CARD")
						break
				else:
					if card.bot_usable == false:
						var random_bot_card = enemy_deck.get_child(rng.randi_range(0, enemy_deck.get_child_count() - 1))
						await get_tree().create_timer(1).timeout
						enemy_deck.get_node(random_bot_card.name).bot_card_use()
						print("BOT: NOT ENOUGH CARDS, USING RANDOM CARD")
						break
					else:
						var random_bot_card = enemy_deck.get_child(rng.randi_range(0, enemy_deck.get_child_count() - 1))
						if enemy_deck.get_node(random_bot_card.name).discardable == true:
							await get_tree().create_timer(1).timeout
							enemy_deck.get_node(random_bot_card.name).bot_card_remove()
							print("BOT: NOT ENOUGH CARDS, DISCARD RANDOM CARD")
							break
		elif cfg.ai_type == 3:
			var random_bot_card = enemy_deck.get_child(rng.randi_range(0, enemy_deck.get_child_count() - 1))
			enemy_deck.get_node(random_bot_card.name).bot_card_use()
			print("RANDOM")
	
	## END GAME
	# Shows a floting window containing info about endgame.
	# TOWER BUILDING VICTORY FOR PLAYER AND ENEMY
	if player_tower_hp >= cfg.tower_victory:
		endgame_screen.set_winner(player_name, tr("TOWER_VICTORY_MSG"), str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	if enemy_tower_hp >= cfg.tower_victory:
		endgame_screen.set_winner(enemy_name, tr("TOWER_VICTORY_MSG"), str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	# TOWER DESTRUCTION VICTORY FOR PLAYER AND ENEMY
	if player_tower_hp <= 0:
		endgame_screen.set_winner(player_name, tr("TOWER_DESTROY_MSG"), str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	if enemy_tower_hp <= 0:
		endgame_screen.set_winner(enemy_name, tr("TOWER_DESTROY_MSG"), str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	# RESOURCE VICTORY FOR PLAYER AND ENEMY
	if player_bricks >= cfg.resource_victory and player_gems >= cfg.resource_victory and player_recruits >= cfg.resource_victory:
		endgame_screen.set_winner(player_name, tr("RESOURCE_VICTORY_MSG"), str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	if enemy_bricks >= cfg.resource_victory and enemy_gems >= cfg.resource_victory and enemy_recruits >= cfg.resource_victory:
		endgame_screen.set_winner(enemy_name, tr("RESOURCE_VICTORY_MSG"), str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true

# PLAYER USE CARD
func use_card(card_name):
	# CARD INIT
	var card_prev = player_deck.get_node(card_name)
	var table = get_node(".")
	var prev_pos = card_prev.get_position_in_parent()
	var card_prev_pos = card_prev.global_position
	deck_locker.show()
	card_prev.usable = false
	card_prev.used = true
	card_prev.mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	# CREATE CARD IN GRAVEYARD
	var card_new = card_prev.duplicate(0)
	graveyard.add_child(card_new, true)
	card_new.get_node("selector").hide()
	card_new.set_modulate(Color(1,1,1,0))
	await graveyard.sort_children # FIX FOR GRAVEYARD MISSING NEW CARD POSITIONS
	card_prev.set_as_top_level(true)
	
	# CARD ANIMATION WITH TWEEN
	# used three tweens for centering the card, moving it to graveyard and fading it away.
	var card_anim = get_node("card_anim")
	var newcard_anim = get_node("newcard_anim")
	card_anim.start()
	card_anim.interpolate_property(card_prev, "position",
		card_prev_pos, (get_viewport_rect().size / 2) - (card_prev.size / 2) + Vector2(0, -50), 1.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	card_anim.interpolate_property(card_prev, "position",
		card_prev.global_position, card_new.global_position, 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished

	card_anim.interpolate_property(card_prev, "modulate",
		Color(1,1,1,1), Color(1,1,1,0.5), 0.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	# remove card_prev and remove it from top level
	card_prev.set_as_top_level(false)
	card_prev.queue_free()
	
	# creating temp card
	var card_temp_file = load("res://scenes/card.tscn")
	var card_temp = card_temp_file.instantiate()
	card_temp.set_modulate(Color(1,1,1,0))
	player_deck.add_child(card_temp)
	player_deck.move_child(card_temp, prev_pos)
	
	card_new.set_modulate(Color(1,1,1,1))
	
	# ADDING A NEW CARD TO DECK
	# animation and instancing itself
	var card_dummy = load("res://scenes/card.tscn")
	var card_dummy_inst = card_dummy.instantiate()
	card_dummy_inst.get_node("card_back").show()
	card_dummy_inst.name = "Dummy Card"
	card_dummy_inst.set_as_top_level(true)
	card_dummy_inst.usable = false
	card_dummy_inst.set_global_position(graveyard.get_node("card_back").get_global_position())
	var card_dummy_pos = card_dummy_inst.get_global_position()
	table.add_child(card_dummy_inst)
	AudioStreamManager.play("res://sounds/deal.ogg")
	newcard_anim.start()
	newcard_anim.interpolate_property(card_dummy_inst, "position",
		card_dummy_pos, card_prev_pos, 1.0,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await newcard_anim.finished
	
	if player_deck.get_child_count() <= cfg.cards_in_hand:
		var card_next = load("res://scenes/card.tscn")
		var card_inst = card_next.instantiate()
		card_inst.add_to_group("player_card")
		card_dummy_inst.queue_free()
		card_temp.queue_free()
		player_deck.add_child(card_inst)
		player_deck.move_child(card_inst, prev_pos)
	
	if player_discarding == true:
		turn = 0
		draw_card_label.show()
		player_draw_card = false
	elif player_play_again == true:
		turn = 0
		player_play_again = false
	else:
		add_resources(turn)
		clear_graveyard()
		await self.graveyard_anim_ended
		turn = 1
	
	deck_locker.hide()

# PLAYER DISCARD CARD
func remove_card(card_name):
	var card_prev = player_deck.get_node(card_name)
	var table = get_node(".")
	var prev_pos = card_prev.get_position_in_parent()
	var card_prev_pos = card_prev.global_position
	deck_locker.show()
	card_prev.usable = false
	card_prev.used = true
	
	# CREATE CARD IN GRAVEYARD
	var card_new = card_prev.duplicate(0)
	graveyard.add_child(card_new, true)
	card_new.get_node("selector").hide()
	card_new.set_modulate(Color(1,1,1,0))
	card_new.mouse_default_cursor_shape = Control.CURSOR_ARROW
	await graveyard.sort_children # FIX FOR GRAVEYARD MISSING NEW CARD POSITIONS
	card_prev.set_as_top_level(true)
	
	# CARD ANIMATION WITH TWEEN
	var card_anim = get_node("card_anim")
	var newcard_anim = get_node("newcard_anim")
	card_anim.start()
	card_anim.interpolate_property(card_prev, "position",
		card_prev_pos, card_new.global_position, 1.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	card_anim.interpolate_property(card_prev, "modulate",
		Color(1,1,1,1), Color(1,1,1,0.5), 0.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	card_prev.set_as_top_level(false)
	card_prev.queue_free()
	card_new.set_modulate(Color(1,1,1,1))
	
	# creating temp card
	var card_temp_file = load("res://scenes/card.tscn")
	var card_temp = card_temp_file.instantiate()
	card_temp.set_modulate(Color(1,1,1,0))
	player_deck.add_child(card_temp)
	player_deck.move_child(card_temp, prev_pos)
	
	# ADDING A NEW CARD TO DECK
	# animation and instancing itself
	var card_dummy = load("res://scenes/card.tscn")
	var card_dummy_inst = card_dummy.instantiate()
	card_dummy_inst.get_node("card_back").show()
	card_dummy_inst.name = "Dummy Card"
	card_dummy_inst.set_as_top_level(true)
	card_dummy_inst.usable = false
	card_dummy_inst.set_global_position(graveyard.get_node("card_back").get_global_position())
	var card_dummy_pos = card_dummy_inst.get_global_position()
	table.add_child(card_dummy_inst)
	AudioStreamManager.play("res://sounds/deal.ogg")
	newcard_anim.start()
	newcard_anim.interpolate_property(card_dummy_inst, "position",
		card_dummy_pos, card_prev_pos, 1.0,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await newcard_anim.finished
	
	if player_deck.get_child_count() <= cfg.cards_in_hand:
		var card_next = load("res://scenes/card.tscn")
		var card_inst = card_next.instantiate()
		card_inst.add_to_group("player_card")
		card_dummy_inst.queue_free()
		card_temp.queue_free()
		player_deck.add_child(card_inst)
		player_deck.move_child(card_inst, prev_pos)
	
	if player_discarding == true:
		turn = 0
		draw_card_label.show()
		player_draw_card = false
	elif player_play_again == true:
		turn = 0
		player_play_again = false
		deck_locker.hide()
	else:
		add_resources(turn)
		deck_locker.hide()
		clear_graveyard()
		await self.graveyard_anim_ended
		turn = 1
	
	deck_locker.hide()

# BOT USE CARD
func bot_use_card(card_name):
	var card_prev = enemy_deck.get_node(card_name)
	var table = get_node(".")
	var prev_pos = card_prev.get_position_in_parent()
	var card_prev_pos = card_prev.global_position
	deck_locker.show()
	card_prev.usable = false
	card_prev.used = true
	card_prev.card_back.hide()
	
	# CREATE CARD IN GRAVEYARD
	var card_new = card_prev.duplicate(0)
	graveyard.add_child(card_new, true)
	card_new.get_node("selector").hide()
	card_new.set_modulate(Color(1,1,1,0))
	await graveyard.sort_children # FIX FOR GRAVEYARD MISSING NEW CARD POSITIONS
	card_prev.set_as_top_level(true)
	
	# CARD ANIMATION WITH TWEEN
	var card_anim = get_node("card_anim")
	card_anim.start()
	card_anim.interpolate_property(card_prev, "position",
		card_prev_pos, (get_viewport_rect().size / 2) - (card_prev.size / 2) + Vector2(0, -50), 1.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	card_anim.interpolate_property(card_prev, "position",
		card_prev.global_position, card_new.global_position, 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	card_anim.interpolate_property(card_prev, "modulate",
		Color(1,1,1,1), Color(1,1,1,0.5), 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	card_prev.set_as_top_level(false)
	card_prev.queue_free()
	card_new.set_modulate(Color(1,1,1,1))
	
	if enemy_deck.get_child_count() <= cfg.cards_in_hand:
		var card_next = load("res://scenes/card.tscn")
		var card_inst = card_next.instantiate()
		card_inst.add_to_group("enemy_card")
		enemy_deck.add_child(card_inst)
		enemy_deck.move_child(card_inst, prev_pos)
		card_inst.card_back.show()
		card_inst.usable = false
		card_inst.discardable = false
	
	if enemy_play_again == true: 
		turn = 1
		enemy_play_again = false
	else:
		add_resources(turn)
		clear_graveyard()
		await self.graveyard_anim_ended
		turn = 0
	AI_ready = true
	deck_locker.hide()

# BOT DISCARD CARD
func bot_remove_card(card_name):
	var card_prev = enemy_deck.get_node(card_name)
	var table = get_node(".")
	var prev_pos = card_prev.get_position_in_parent()
	var card_prev_pos = card_prev.global_position
	deck_locker.show()
	card_prev.usable = false
	card_prev.used = true
	card_prev.card_back.hide()
	
	# CREATE CARD IN GRAVEYARD
	var card_new = card_prev.duplicate(0)
	graveyard.add_child(card_new, true)
	card_new.get_node("selector").hide()
	card_new.set_modulate(Color(1,1,1,0))
	await graveyard.sort_children # FIX FOR GRAVEYARD MISSING NEW CARD POSITIONS
	card_prev.set_as_top_level(true)
	
	var card_anim = get_node("card_anim")
	card_anim.start()
	card_anim.interpolate_property(card_prev, "position",
		card_prev.global_position, card_new.global_position, 1.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	card_anim.interpolate_property(card_prev, "modulate",
		Color(1,1,1,1), Color(1,1,1,0.5), 0.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	await card_anim.finished
	
	card_prev.set_as_top_level(false)
	card_prev.queue_free()
	card_new.set_modulate(Color(1,1,1,1))
	if enemy_discarding == true:
		turn = 1
		draw_card_label.show()
		player_draw_card = false
	elif enemy_play_again == true:
		turn = 1
		player_play_again = false
		deck_locker.hide()
	else:
		add_resources(turn)
		deck_locker.hide()
		clear_graveyard()
		await self.graveyard_anim_ended
		AI_ready = true
		turn = 0
	if enemy_deck.get_child_count() <= cfg.cards_in_hand:
		var card_next = load("res://scenes/card.tscn")
		var card_inst = card_next.instantiate()
		enemy_deck.add_child(card_inst)
		enemy_deck.move_child(card_inst, prev_pos)
		card_inst.add_to_group("enemy_card")
		card_inst.card_back.show()

func update_stat_panels():
	# PLAYER STATS
	player_bricks_per_panel.text = str(player_quarry)
	player_bricks_per_panel_alt.text = str(player_quarry)
	player_bricks_total_panel.text = str(player_bricks)
	player_bricks_total_panel_alt.text = str(player_bricks)
	player_gems_per_panel.text = str(player_magic)
	player_gems_per_panel_alt.text = str(player_magic)
	player_gems_total_panel.text = str(player_gems)
	player_gems_total_panel_alt.text = str(player_gems)
	player_recruits_per_panel.text = str(player_dungeon)
	player_recruits_per_panel_alt.text = str(player_dungeon)
	player_recruits_total_panel.text = str(player_recruits)
	player_recruits_total_panel_alt.text = str(player_recruits)
	# ENEMY STATS
	enemy_bricks_per_panel.text = str(enemy_quarry)
	enemy_bricks_per_panel_alt.text = str(enemy_quarry)
	enemy_bricks_total_panel.text = str(enemy_bricks)
	enemy_bricks_total_panel_alt.text = str(enemy_bricks)
	enemy_gems_per_panel.text = str(enemy_magic)
	enemy_gems_per_panel_alt.text = str(enemy_magic)
	enemy_gems_total_panel.text = str(enemy_gems)
	enemy_gems_total_panel_alt.text = str(enemy_gems)
	enemy_recruits_per_panel.text = str(enemy_dungeon)
	enemy_recruits_per_panel_alt.text = str(enemy_dungeon)
	enemy_recruits_total_panel.text = str(enemy_recruits)
	enemy_recruits_total_panel_alt.text = str(enemy_recruits)
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

func locale_stat_panels():
	if TranslationServer.get_locale() == "en":
		switch_stat_panels(false)
	else:
		switch_stat_panels(true)

func switch_stat_panels(do):
	if do == false:
		# SHOW
		player_bricks_panel.show()
		player_gems_panel.show()
		player_recruits_panel.show()
		enemy_bricks_panel.show()
		enemy_gems_panel.show()
		enemy_recruits_panel.show()
		# HIDE
		player_bricks_panel_alt.hide()
		player_gems_panel_alt.hide()
		player_recruits_panel_alt.hide()
		enemy_bricks_panel_alt.hide()
		enemy_gems_panel_alt.hide()
		enemy_recruits_panel_alt.hide()
	elif do == true:
		# SHOW
		player_bricks_panel_alt.show()
		player_gems_panel_alt.show()
		player_recruits_panel_alt.show()
		enemy_bricks_panel_alt.show()
		enemy_gems_panel_alt.show()
		enemy_recruits_panel_alt.show()
		# HIDE
		player_bricks_panel.hide()
		player_gems_panel.hide()
		player_recruits_panel.hide()
		enemy_bricks_panel.hide()
		enemy_gems_panel.hide()
		enemy_recruits_panel.hide()

func add_resources(turn):
	if turn == 0:
		player_bricks += player_quarry
		player_gems += player_magic
		player_recruits += player_dungeon
	if turn == 1:
		enemy_bricks += enemy_quarry
		enemy_gems += enemy_magic
		enemy_recruits += enemy_dungeon

func play_audio(audio_name: String): #TODO: FIX AUDIO
	var player = AudioStreamPlayer.new()
	player.set_name(str(audio_name))
	player.set_bus("Sounds")
	player.set_stream(load("res://sounds/" + str(audio_name) + ".ogg"))
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()

func emit_particles(type): # PARTICLE EMITTING
	match type:
		# PLAYER AND ENEMY TOWER AND WALLS DAMAGE
		"damage_player_tower":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_tower.global_position - $player_tower.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"damage_player_wall":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_wall.global_position - $player_wall.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"damage_enemy_tower":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_tower.global_position - $enemy_tower.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"damage_enemy_wall":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_wall.global_position - $enemy_wall.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		# PLAYER RESOURCES REMOVE
		"remove_player_quarry":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_bricks_panel/per_turn.global_position + $player_bricks_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_player_bricks":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_bricks_panel/total.global_position + $player_bricks_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_player_magic":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_gems_panel/per_turn.global_position + $player_gems_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_player_gems":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_gems_panel/total.global_position + $player_gems_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_player_dungeons":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_recruits_panel/per_turn.global_position + $player_recruits_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_player_recruits":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_recruits_panel/total.global_position + $player_recruits_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		# ENEMY RESOURCES REMOVE
		"remove_enemy_quarry":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_bricks_panel/per_turn.global_position + $enemy_bricks_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_enemy_bricks":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_bricks_panel/total.global_position + $enemy_bricks_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_enemy_magic":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_gems_panel/per_turn.global_position + $enemy_gems_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_enemy_gems":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_gems_panel/total.global_position + $enemy_gems_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_enemy_dungeons":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_recruits_panel/per_turn.global_position + $enemy_recruits_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"remove_enemy_recruits":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_recruits_panel/total.global_position + $enemy_recruits_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		# PLAYER AND ENEMY TOWER AND WALLS HEAL
		"heal_player_tower":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_tower.global_position - $player_tower.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"heal_player_wall":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_wall.global_position - $player_wall.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"heal_enemy_tower":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_tower.global_position - $enemy_tower.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"heal_enemy_wall":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_wall.global_position - $enemy_wall.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		# PLAYER RESOURCES ADD
		"add_player_quarry":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_bricks_panel/per_turn.global_position + $player_bricks_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_player_bricks":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_bricks_panel/total.global_position + $player_bricks_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_player_magic":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_gems_panel/per_turn.global_position + $player_gems_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_player_gems":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_gems_panel/total.global_position + $player_gems_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_player_dungeons":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_recruits_panel/per_turn.global_position + $player_recruits_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_player_recruits":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $player_recruits_panel/total.global_position + $player_recruits_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		# ENEMY RESOURCES ADD
		"add_enemy_quarry":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_bricks_panel/per_turn.global_position + $enemy_bricks_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_enemy_bricks":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_bricks_panel/total.global_position + $enemy_bricks_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_enemy_magic":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_gems_panel/per_turn.global_position + $enemy_gems_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_enemy_gems":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_gems_panel/total.global_position + $enemy_gems_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_enemy_dungeons":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_recruits_panel/per_turn.global_position + $enemy_recruits_panel/per_turn.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()
		"add_enemy_recruits":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instantiate()
			particle_inst.position = $enemy_recruits_panel/total.global_position + $enemy_recruits_panel/total.size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			await get_tree().create_timer(3).timeout
			particle_inst.queue_free()

func _on_Time_Elapsed_timeout(): # PLAYTIME FOR LEADERBOARD
	elapsed += 1
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	str_elapsed = "%02d:%02d" % [minutes, seconds]

func clear_graveyard():
	if graveyard.get_child_count() >= 2:
		for i in range(1, graveyard.get_child_count()):
			var card = graveyard.get_child(i)
			var card_anim = get_node("graveyard_anim")
			card_anim.start()
			
			card_anim.interpolate_property(card, "position",
				card.position, card_back.position, 1,
				Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
			
			card_anim.interpolate_property(card, "modulate",
				Color(1,1,1,1), Color(1,1,1,0), 1.5,
				Tween.TRANS_EXPO, Tween.EASE_IN_OUT)

func _on_graveyard_anim_tween_all_completed():
	for i in range(1, graveyard.get_child_count()):
		var card = graveyard.get_child(i)
		emit_signal("graveyard_anim_ended")
		card.queue_free()
