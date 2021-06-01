extends Control

export(String, FILE, "*tscn") var play_scene
export(String, FILE, "*tscn") var tutorial_scene
export(String, FILE, "*tscn") var credits_scene

onready var t := $Tween

func _ready():
	t.interpolate_property($Title, "rect_position:y", 600, 10, 0.4, Tween.TRANS_SINE, Tween.EASE_OUT, 0.3)
	t.interpolate_property($Title, "rect_position:y", 10, 100, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT, 0.7)
	t.interpolate_property($Play, "rect_position:x", -282, 18, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT, 1.0)
	t.interpolate_property($Tutorial, "rect_position:x", -282, 18, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT, 1.1)
	t.interpolate_property($Credits, "rect_position:x", 1027, 737, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT, 1.2)
	t.start()


func _on_Play_pressed():
	Global.goto_scene(play_scene)


func _on_Tutorial_pressed():
	Global.goto_scene(tutorial_scene)


func _on_Credits_pressed():
	Global.goto_scene(credits_scene)
