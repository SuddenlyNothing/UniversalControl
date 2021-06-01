extends TileMap

onready var timer := $Timer

func _ready():
	Global.tilemap = self

func alert():
	for cell in get_used_cells_by_id(1):
		set_cellv(cell, 2)
		timer.start()
		yield(timer, "timeout")
