extends Control

onready var device_ip_addr = $device_ip_addr

func _ready():
	device_ip_addr.text = Network.ip_address

func _on_create_server_pressed():
	pass # Replace with function body.

func _on_join_server_pressed():
	pass # Replace with function body.

func _on_cancel_pressed():
	self.hide()
