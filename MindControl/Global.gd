extends Node2D

onready var fade := $CanvasLayer/Fade
onready var timer := $Timer
onready var pause:= $CanvasLayer/Pause

onready var alarm_sfx := $Alarm
onready var alarm_t := $Alarm/Tween
var previous_scene = null
var current_scene = null

var tilemap = null
var navigation = null

var camera = null

var scared = false

var alerted = false

func _ready():
	fade.fade_in()
	OS.window_maximized = true
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )

func goto_scene(path):
	get_tree().paused = true
	previous_scene = current_scene.filename
	fade.fade_out()
	yield(fade, "faded_out")
	call_deferred("_deferred_goto_scene",path)

func _deferred_goto_scene(path):
	alarm_sfx.stop()
	alerted = false
	# Immediately free the current scene,
	# there is no risk here.
	current_scene.free()

	# Load new scene
	var s = ResourceLoader.load(path)

	# Instance the new scene
	current_scene = s.instance()

	# Add it to the active scene, as child of root
	get_tree().get_root().add_child(current_scene)

	# optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene( current_scene )
	fade.fade_in()
	set_process(true)
	pause.unpause()

func lose():
	set_process(false)
	if camera != null:
		get_tree().paused = true
		camera.track_group = "loser"
		timer.start()
		yield(timer, "timeout")
	fade.fade_out()
	yield(fade, "faded_out")
	call_deferred("_deferred_goto_scene",current_scene.filename)
	get_tree().paused = false

func _process(_delta):
	if alerted:
		return
	if get_tree().get_nodes_in_group("infected").size() >= 3:
		alert()

func alert():
	alerted = true
	tilemap.alert()
	for turret in get_tree().get_nodes_in_group("turrets"):
		turret.start()
	camera.zoom_out()
	play_alarm()

func play_alarm():
	alarm_sfx.play()
	alarm_t.interpolate_property(alarm_sfx, "volume_db", 0, -30, 4, Tween.TRANS_SINE, Tween.EASE_IN)
	alarm_t.start()
	yield(alarm_t, "tween_all_completed")
	alarm_sfx.stop()






