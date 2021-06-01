extends Control

export(String, FILE, "*tscn") var menu_scene

func _on_Button_pressed():
	Global.goto_scene(menu_scene)
