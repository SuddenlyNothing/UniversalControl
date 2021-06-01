extends Node2D

export(String, FILE, "*tscn") var next_scene

func win():
	Global.goto_scene(next_scene)
