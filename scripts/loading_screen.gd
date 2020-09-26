extends Control

onready var tween = get_node("tween")
onready var bar = get_node("bar")

func update_percent(new_percent):
	tween.start()
	tween.interpolate_property(bar, "value", bar.value, new_percent, 0.005, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	yield(tween, "tween_completed")
