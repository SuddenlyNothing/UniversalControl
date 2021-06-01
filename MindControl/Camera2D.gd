extends Camera2D

onready var zoom_out_timer := $ZoomOutTimer
onready var t := $Tween

export(float) var max_zoom := 0.7
export(float) var min_zoom := 0.2

var track_group := "infected"

# viewport size = (1024, 600)

var zoomed := true

func _ready():
	Global.camera = self

func _process(delta):
	if zoomed:
		if (Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") or
			Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down")):
				t.interpolate_property($CanvasLayer/Label, "modulate:a", 1, 0, 0.5)
				t.start()
				zoomed = false
	var tracking := get_tree().get_nodes_in_group(track_group)
	if tracking.size() == 0:
		return
	var min_x = null
	var min_y
	var max_x
	var max_y
	for node in tracking:
		var pos = node.position
		if min_x == null:
			min_x = pos.x
			max_x = pos.x
			min_y = pos.y
			max_y = pos.y
		else:
			if pos.x > max_x:
				max_x = pos.x
			elif pos.x < min_x:
				min_x = pos.x

			if pos.y > max_y:
				max_y = pos.y
			elif pos.y < min_y:
				min_y = pos.y
	if min_x != null:
		var largest_zoom
		if !zoom_out_timer.is_stopped() or zoomed:
			largest_zoom = max_zoom
		else:
			largest_zoom = clamp(max(abs(max_y-min_y)/600, abs(max_x-min_x)/1024) * 3+(0.1*(tracking.size())), min_zoom, max_zoom)
		zoom = zoom.linear_interpolate(Vector2(largest_zoom, largest_zoom), 0.05)
		position = Vector2((max_x+min_x)/2, (max_y+min_y)/2)

func zoom_out():
	zoom_out_timer.start()
