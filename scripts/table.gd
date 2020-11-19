extends Control

var rng = RandomNumberGenerator.new()

onready var particles = $particles
onready var card_back = $graveyard/card_back
onready var graveyard = $graveyard
onready var draw_card_label = $draw_card_label
onready var endgame_screen = $endgame
onready var time_elapsed = $Time_Elapsed

var player_name = "DarkPro1337"
var enemy_name = "COMPUTER"

enum players {red, blue} # TODO
var turn
var AI_ready = true
var player_play_again = false
var enemy_play_again = false
var player_discarding = false
var enemy_discarding = false
var player_draw_card = false
var enemy_draw_card = false

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

var time_start = 0
var time_now = 0
var elapsed = 0
var str_elapsed = "00:00"

signal graveyard_anim_ended

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://scenes/main_menu.tscn")

func _ready():
	global.table = self
	rng.randomize()
	turn = rng.randi_range(0, players.size() - 1)
	add_resources(turn)
	$player_panel/player_name.text = player_name
	$enemy_panel/enemy_name.text = enemy_name
	
	# PLAYER START DECK GENERATION
	while $player_deck.get_child_count() != 6:
		var card = load("res://scenes/card.tscn")
		var card_inst = card.instance()
		card_inst.add_to_group("player_card")
		$player_deck.add_child(card_inst)
		card_inst.usable = true
	
	# ENEMY START DECK GENERATION
	while $enemy_deck.get_child_count() != 6:
		var card = load("res://scenes/card.tscn")
		var card_inst = card.instance()
		card_inst.add_to_group("enemy_card")
		$enemy_deck.add_child(card_inst)
		card_inst.card_back.show()
		card_inst.usable = false

func _physics_process(delta):
	update_stat_panels()
	if turn == 0:
		$player_deck.show()
		$enemy_deck.hide()
	elif turn == 1 and AI_ready == true:
		AI_ready = false
		$player_deck.hide()
		$enemy_deck.show()
		
		#var random_bot_card = $enemy_deck.get_child(rng.randi_range(0, $enemy_deck.get_child_count() - 1))
		#$enemy_deck.get_node(random_bot_card.name).bot_card_use()
		
		# ARCOMAGE BOT v.0.2
		# DON'T TRY TO UNDERSTAND THIS, LOL
		var bot_atk_card_count = 0
		var bot_def_card_count = 0
		var bot_res_card_count = 0
		
		# GET CURRENT NUMBERS OF ATK, DEF AND RES CARDS IN DECK
		for i in $enemy_deck.get_child_count():
			var card = $enemy_deck.get_child(i)
			if card.card_use == 0: #atk
				bot_atk_card_count += 1
			elif card.card_use == 1: #def
				bot_def_card_count += 1
			elif card.card_use == 2: #res
				bot_res_card_count += 1
		
		for i in $enemy_deck.get_child_count():
			var card = $enemy_deck.get_child(i)
			if enemy_discarding == true and card.bot_usable == true:
				if card.card_use == 2: #res
					yield(get_tree().create_timer(1), "timeout")
					$enemy_deck.get_node(card.name).bot_card_remove()
					print("BOT: REMOVING RESORCE CARD")
					enemy_discarding = false
					break
				else:
					var random_bot_card = $enemy_deck.get_child(rng.randi_range(0, $enemy_deck.get_child_count() - 1))
					yield(get_tree().create_timer(1), "timeout")
					$enemy_deck.get_node(random_bot_card.name).bot_card_remove()
					print("BOT: NOT ENOUGH CARDS, DISCARD RANDOM CARD")
					break
			elif (enemy_tower_hp + enemy_wall_hp) >= (player_tower_hp + player_wall_hp) and bot_atk_card_count != 0 and card.bot_usable == true:
				if card.card_use == 0: #atk
					yield(get_tree().create_timer(1), "timeout")
					$enemy_deck.get_node(card.name).bot_card_use()
					print("BOT: USING ATTACK CARD")
					break
			elif (enemy_tower_hp + enemy_wall_hp) <= (player_tower_hp + player_wall_hp) and bot_def_card_count != 0 and card.bot_usable == true:
				if card.card_use == 1: #def
					yield(get_tree().create_timer(1), "timeout")
					$enemy_deck.get_node(card.name).bot_card_use()
					print("BOT: USING DEFENCE CARD")
					break
			elif (enemy_tower_hp + enemy_wall_hp) == (player_tower_hp + player_wall_hp) and bot_res_card_count != 0 and card.bot_usable == true:
				if card.card_use == 2: #res
					yield(get_tree().create_timer(1), "timeout")
					$enemy_deck.get_node(card.name).bot_card_use()
					print("BOT: USING RESORCE CARD")
					break
			else:
				if card.bot_usable == false:
					var random_bot_card = $enemy_deck.get_child(rng.randi_range(0, $enemy_deck.get_child_count() - 1))
					yield(get_tree().create_timer(1), "timeout")
					$enemy_deck.get_node(random_bot_card.name).bot_card_use()
					print("BOT: NOT ENOUGH CARDS, USING RANDOM CARD")
					break
				else:
					var random_bot_card = $enemy_deck.get_child(rng.randi_range(0, $enemy_deck.get_child_count() - 1))
					if $enemy_deck.get_node(random_bot_card.name).discardable == true:
						yield(get_tree().create_timer(1), "timeout")
						$enemy_deck.get_node(random_bot_card.name).bot_card_remove()
						print("BOT: NOT ENOUGH CARDS, DISCARD RANDOM CARD")
						break
					else:
						print("BOT: NOT DISCARDABLE CARD, CONTINUE")
	
	## END GAME
	# TOWER BUILDING VICTORY FOR PLAYER AND ENEMY
	if player_tower_hp >= cfg.tower_victory:
		endgame_screen.set_winner(player_name, "BY A TOWER BUILDING VICTORY!!!", str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	if enemy_tower_hp >= cfg.tower_victory:
		endgame_screen.set_winner(enemy_name, "BY A TOWER BUILDING VICTORY!!!", str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	# TOWER DESTRUCTION VICTORY FOR PLAYER AND ENEMY
	if player_tower_hp <= 0:
		endgame_screen.set_winner(player_name, "BY A TOWER DESTRUCTION VICTORY!!!", str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	if enemy_tower_hp <= 0:
		endgame_screen.set_winner(enemy_name, "BY A TOWER DESTRUCTION VICTORY!!!", str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	# RESOURCE VICTORY FOR PLAYER AND ENEMY
	if player_bricks >= cfg.resource_victory and player_gems >= cfg.resource_victory and player_recruits >= cfg.resource_victory:
		endgame_screen.set_winner(player_name, "BY A TOWER DESTRUCTION VICTORY!!!", str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
	if enemy_bricks >= cfg.resource_victory and enemy_gems >= cfg.resource_victory and enemy_recruits >= cfg.resource_victory:
		endgame_screen.set_winner(enemy_name, "BY A TOWER DESTRUCTION VICTORY!!!", str_elapsed)
		time_elapsed.stop()
		get_tree().paused = true
# PLAYER USE CARD
func use_card(card_name):
	var card_prev = $player_deck.get_node(card_name)
	var table = get_node(".")
	var prev_pos = card_prev.get_position_in_parent()
	var card_prev_pos = card_prev.rect_global_position
	$deck_locker.show()
	card_prev.usable = false
	card_prev.used = true
	card_prev.mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	# CREATE CARD IN GRAVEYARD
	var card_new = card_prev.duplicate(0)
	graveyard.add_child(card_new, true)
	card_new.get_node("selector").hide()
	card_new.set_modulate(Color(1,1,1,0))
	yield(graveyard, "sort_children") # FIX FOR GRAVEYARD MISSING NEW CARD POSITIONS
	card_prev.set_as_toplevel(true)
	
	# CARD ANIMATION WITH TWEEN
	var card_anim = get_node("card_anim")
	card_anim.start()
	card_anim.interpolate_property(card_prev, "rect_position",
		card_prev_pos, (get_viewport_rect().size / 2) - (card_prev.rect_size / 2) + Vector2(0, -50), 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_anim.interpolate_property(card_prev, "rect_position",
		card_prev.rect_global_position, card_new.rect_global_position, 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")

	card_anim.interpolate_property(card_prev, "modulate",
		Color(1,1,1,1), Color(1,1,1,0.5), 0.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_prev.set_as_toplevel(false)
	card_prev.queue_free()
	card_new.set_modulate(Color(1,1,1,1))
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
		yield(self, "graveyard_anim_ended")
		turn = 1
	
	$deck_locker.hide()
	if $player_deck.get_child_count() <= 6:
		var card_next = load("res://scenes/card.tscn")
		var card_inst = card_next.instance()
		card_inst.add_to_group("player_card")
		$player_deck.add_child(card_inst)
		$player_deck.move_child(card_inst, prev_pos)

# PLAYER DISCARD CARD
func remove_card(card_name):
	var card_prev = $player_deck.get_node(card_name)
	var table = get_node(".")
	var prev_pos = card_prev.get_position_in_parent()
	var card_prev_pos = card_prev.rect_global_position
	$deck_locker.show()
	card_prev.usable = false
	card_prev.used = true
	
	# CREATE CARD IN GRAVEYARD
	var card_new = card_prev.duplicate(0)
	graveyard.add_child(card_new, true)
	card_new.get_node("selector").hide()
	card_new.set_modulate(Color(1,1,1,0))
	card_new.mouse_default_cursor_shape = Control.CURSOR_ARROW
	yield(graveyard, "sort_children") # FIX FOR GRAVEYARD MISSING NEW CARD POSITIONS
	card_prev.set_as_toplevel(true)
	
	# CARD ANIMATION WITH TWEEN
	var card_anim = get_node("card_anim")
	card_anim.start()
	card_anim.interpolate_property(card_prev, "rect_position",
		card_prev_pos, card_new.rect_global_position, 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_anim.interpolate_property(card_prev, "modulate",
		Color(1,1,1,1), Color(1,1,1,0.5), 0.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_prev.set_as_toplevel(false)
	card_prev.queue_free()
	card_new.set_modulate(Color(1,1,1,1))
	if player_discarding == true:
		turn = 0
		draw_card_label.show()
		player_draw_card = false
	elif player_play_again == true:
		turn = 0
		player_play_again = false
		$deck_locker.hide()
	else:
		add_resources(turn)
		$deck_locker.hide()
		clear_graveyard()
		yield(self, "graveyard_anim_ended")
		turn = 1
	if $player_deck.get_child_count() <= 6:
		var card_next = load("res://scenes/card.tscn")
		var card_inst = card_next.instance()
		$player_deck.add_child(card_inst)
		$player_deck.move_child(card_inst, prev_pos)
		card_inst.add_to_group("player_card")

func bot_use_card(card_name):
	var card_prev = $enemy_deck.get_node(card_name)
	var table = get_node(".")
	var prev_pos = card_prev.get_position_in_parent()
	var card_prev_pos = card_prev.rect_global_position
	$deck_locker.show()
	card_prev.usable = false
	card_prev.used = true
	card_prev.card_back.hide()
	
	# CREATE CARD IN GRAVEYARD
	var card_new = card_prev.duplicate(0)
	graveyard.add_child(card_new, true)
	card_new.get_node("selector").hide()
	card_new.set_modulate(Color(1,1,1,0))
	yield(graveyard, "sort_children") # FIX FOR GRAVEYARD MISSING NEW CARD POSITIONS
	card_prev.set_as_toplevel(true)
	
	# CARD ANIMATION WITH TWEEN
	var card_anim = get_node("card_anim")
	card_anim.start()
	card_anim.interpolate_property(card_prev, "rect_position",
		card_prev_pos, (get_viewport_rect().size / 2) - (card_prev.rect_size / 2) + Vector2(0, -50), 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_anim.interpolate_property(card_prev, "rect_position",
		card_prev.rect_global_position, card_new.rect_global_position, 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_anim.interpolate_property(card_prev, "modulate",
		Color(1,1,1,1), Color(1,1,1,0.5), 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_prev.set_as_toplevel(false)
	card_prev.queue_free()
	card_new.set_modulate(Color(1,1,1,1))
	
	if enemy_play_again == true: 
		turn = 1
		enemy_play_again = false
	else:
		add_resources(turn)
		clear_graveyard()
		yield(self, "graveyard_anim_ended")
		turn = 0
	AI_ready = true
	$deck_locker.hide()
	if $enemy_deck.get_child_count() <= 6:
		var card_next = load("res://scenes/card.tscn")
		var card_inst = card_next.instance()
		card_inst.add_to_group("enemy_card")
		$enemy_deck.add_child(card_inst)
		$enemy_deck.move_child(card_inst, prev_pos)
		card_inst.card_back.show()
		card_inst.usable = false
		card_inst.discardable = false

func bot_remove_card(card_name):
	var card_prev = $enemy_deck.get_node(card_name)
	var table = get_node(".")
	var prev_pos = card_prev.get_position_in_parent()
	var card_prev_pos = card_prev.rect_global_position
	$deck_locker.show()
	card_prev.usable = false
	card_prev.used = true
	card_prev.card_back.hide()
	
	# CREATE CARD IN GRAVEYARD
	var card_new = card_prev.duplicate(0)
	graveyard.add_child(card_new, true)
	card_new.get_node("selector").hide()
	card_new.set_modulate(Color(1,1,1,0))
	yield(graveyard, "sort_children") # FIX FOR GRAVEYARD MISSING NEW CARD POSITIONS
	card_prev.set_as_toplevel(true)
	
	var card_anim = get_node("card_anim")
	card_anim.start()
	card_anim.interpolate_property(card_prev, "rect_position",
		card_prev.rect_global_position, card_new.rect_global_position, 1,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_anim.interpolate_property(card_prev, "modulate",
		Color(1,1,1,1), Color(1,1,1,0.5), 0.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(card_anim, "tween_completed")
	
	card_prev.set_as_toplevel(false)
	card_prev.queue_free()
	card_new.set_modulate(Color(1,1,1,1))
	if enemy_discarding == true:
		turn = 1
		draw_card_label.show()
		player_draw_card = false
	elif enemy_play_again == true:
		turn = 1
		player_play_again = false
		$deck_locker.hide()
	else:
		add_resources(turn)
		$deck_locker.hide()
		clear_graveyard()
		AI_ready = true
		turn = 0
	if $enemy_deck.get_child_count() <= 6:
		var card_next = load("res://scenes/card.tscn")
		var card_inst = card_next.instance()
		$enemy_deck.add_child(card_inst)
		$enemy_deck.move_child(card_inst, prev_pos)
		card_inst.add_to_group("enemy_card")
		card_inst.card_back.show()

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
	yield(player, "finished")
	player.queue_free()

func emit_particles(type): # PARTICLE EMITTING
	match type:
		# PLAYER AND ENEMY TOWER AND WALLS DAMAGE
		"damage_player_tower":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_tower.rect_global_position - $player_tower.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"damage_player_wall":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_wall.rect_global_position - $player_wall.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"damage_enemy_tower":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_tower.rect_global_position - $enemy_tower.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"damage_enemy_wall":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_wall.rect_global_position - $enemy_wall.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		# PLAYER RESOURCES REMOVE
		"remove_player_quarry":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_bricks_panel/per_turn.rect_global_position + $player_bricks_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_player_bricks":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_bricks_panel/total.rect_global_position + $player_bricks_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_player_magic":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_gems_panel/per_turn.rect_global_position + $player_gems_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_player_gems":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_gems_panel/total.rect_global_position + $player_gems_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_player_dungeons":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_recruits_panel/per_turn.rect_global_position + $player_recruits_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_player_recruits":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_recruits_panel/total.rect_global_position + $player_recruits_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		# ENEMY RESOURCES REMOVE
		"remove_enemy_quarry":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_bricks_panel/per_turn.rect_global_position + $enemy_bricks_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_enemy_bricks":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_bricks_panel/total.rect_global_position + $enemy_bricks_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_enemy_magic":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_gems_panel/per_turn.rect_global_position + $enemy_gems_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_enemy_gems":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_gems_panel/total.rect_global_position + $enemy_gems_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_enemy_dungeons":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_recruits_panel/per_turn.rect_global_position + $enemy_recruits_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"remove_enemy_recruits":
			var particle = load("res://scenes/particles/damage.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_recruits_panel/total.rect_global_position + $enemy_recruits_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		# PLAYER AND ENEMY TOWER AND WALLS HEAL
		"heal_player_tower":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_tower.rect_global_position - $player_tower.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"heal_player_wall":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_wall.rect_global_position - $player_wall.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"heal_enemy_tower":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_tower.rect_global_position - $enemy_tower.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"heal_enemy_wall":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_wall.rect_global_position - $enemy_wall.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		# PLAYER RESOURCES ADD
		"add_player_quarry":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_bricks_panel/per_turn.rect_global_position + $player_bricks_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_player_bricks":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_bricks_panel/total.rect_global_position + $player_bricks_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_player_magic":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_gems_panel/per_turn.rect_global_position + $player_gems_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_player_gems":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_gems_panel/total.rect_global_position + $player_gems_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_player_dungeons":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_recruits_panel/per_turn.rect_global_position + $player_recruits_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_player_recruits":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $player_recruits_panel/total.rect_global_position + $player_recruits_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		# ENEMY RESOURCES ADD
		"add_enemy_quarry":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_bricks_panel/per_turn.rect_global_position + $enemy_bricks_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_enemy_bricks":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_bricks_panel/total.rect_global_position + $enemy_bricks_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_enemy_magic":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_gems_panel/per_turn.rect_global_position + $enemy_gems_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_enemy_gems":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_gems_panel/total.rect_global_position + $enemy_gems_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_enemy_dungeons":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_recruits_panel/per_turn.rect_global_position + $enemy_recruits_panel/per_turn.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()
		"add_enemy_recruits":
			var particle = load("res://scenes/particles/heal.tscn")
			var particle_inst = particle.instance()
			particle_inst.position = $enemy_recruits_panel/total.rect_global_position + $enemy_recruits_panel/total.rect_size / 2
			particles.add_child(particle_inst)
			particle_inst.set_emitting(true)
			yield(get_tree().create_timer(3), "timeout")
			particle_inst.queue_free()

func _on_Time_Elapsed_timeout(): # PLAYTIME FOR LEADERBOARD
	elapsed += 1
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	str_elapsed = "%02d:%02d" % [minutes, seconds]

func clear_graveyard():
	for i in range(1, graveyard.get_child_count()):
		var card = graveyard.get_child(i)
		var card_anim = get_node("graveyard_anim")
		card_anim.start()
		
		card_anim.interpolate_property(card, "rect_position",
			card.rect_position, card_back.rect_position, 1,
			Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		
		card_anim.interpolate_property(card, "modulate",
			Color(1,1,1,1), Color(1,1,1,0), 1.5,
			Tween.TRANS_EXPO, Tween.EASE_IN_OUT)

func _on_graveyard_anim_tween_all_completed():
	for i in range(1, graveyard.get_child_count()):
		var card = graveyard.get_child(i)
		emit_signal("graveyard_anim_ended")
		card.queue_free()
