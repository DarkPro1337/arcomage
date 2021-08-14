extends Node

## BOOT SCRIPT

func _init():
	build_number()

# Print version and buld and decide where we want player to start...
func _ready():
	print(global.time() + "Arcoamge v." + ProjectSettings.get_setting("application/config/version") + " loaded!")
	print("Build number: " + str(global.build))
	print(global.time() + "Boot loaded.")
	if cfg.intro_skip == false:
		get_tree().change_scene("res://scenes/intro.tscn")
		print(global.time() + "Loading to the Intro...")
	elif cfg.intro_skip == true:
		get_tree().change_scene("res://scenes/main_menu.tscn")
		print(global.time() + "Loading to the Main menu...")

# Generate build number from current date if in Debug Mode
func build_number():
	if OS.is_debug_build() == true:
		save_build_number(generate_build_number())

# Save build number as file
func save_build_number(build_number):
	var file = File.new()
	file.open("res://build.tres", File.WRITE)
	file.store_string(build_number)
	file.close()

# Geneate build number from current date
func generate_build_number():
	var date = OS.get_date()
	var day = str(date.get("day"))
	var month = str(date.get("month"))
	var year = str(date.get("year"))
	if day.length() == 1:
		day = "0" + day
	if month.length() == 1:
		month = "0" + month
	return day + month + year
