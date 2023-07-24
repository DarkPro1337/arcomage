extends Control

@onready var multiplayer_config_ui = $container
@onready var server_ip_address = $container/ip_addr
@onready var device_ip_addr = $device_ip_addr

func _ready():
	get_tree().connect("peer_connected",Callable(self,"_player_connected"))
	get_tree().connect("peer_disconnected",Callable(self,"_player_disconnected"))
	# get_tree().connect("connected_to_server",Callable(self,"_connected_to_server"))
	
	device_ip_addr.text = Network.ip_address
	
	Network.connect("server_created",Callable(self,"_on_ready_to_play"))
	Network.connect("join_success",Callable(self,"_on_ready_to_play"))
	Network.connect("join_fail",Callable(self,"_on_join_fail"))

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected!")

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected!")

func _on_create_server_pressed():
	Network.create_server()
	multiplayer_config_ui.hide()

func _on_join_server_pressed():
	if server_ip_address.text != "":
		Network.ip_address = server_ip_address.text
		Network.join_server()
		multiplayer_config_ui.hide()

func _on_cancel_pressed():
	self.hide()

func _on_ready_to_play():
	get_tree().change_scene_to_file("res://scenes/table.tscn")

func _on_join_fail():
	multiplayer_config_ui.show()
	print("Failed to join server")
