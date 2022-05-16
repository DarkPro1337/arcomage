extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 2 # TODO: in longterm this should be updated up to 4 players

var server = null
var client = null

var ip_address = ""

var players = {}

signal server_created
signal join_success
signal join_fail
signal player_list_changed

func _ready() -> void:
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
	
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	if (server.create_server(DEFAULT_PORT, MAX_CLIENTS) != OK):
		print(global.time() + "Failed to create server!")
		return
	get_tree().set_network_peer(server)
	emit_signal("server_created")
	print(global.time() + "Server started at " + str(DEFAULT_PORT))

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	if (client.create_client(ip_address, DEFAULT_PORT) != OK):
		print(global.time() + "Failed to join server")
		emit_signal("join_fail")
		return
	get_tree().set_network_peer(client)

func _on_connected_to_server() -> void:
	emit_signal("join_success")
	print(global.time() + "Successfully connected to the server!")

func _on_disconnected_from_server() -> void:
	print(global.time() + "Disconnected from server!")

func _on_player_connected(id):
	pass

func _on_player_disconnected(id):
	pass

func _on_connection_failed():
	emit_signal("join_fail")
	get_tree().set_network_peer(null)
	print(global.time() + "Connection failed!")
