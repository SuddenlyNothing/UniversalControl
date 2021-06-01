extends StaticBody2D

onready var bullet_timer := $BulletTimer
onready var bullet_start_pos := $BulletStartPos
onready var anim_player := $AnimationPlayer

onready var Bullet = preload("res://Environment/Bullet.tscn")

var started = false

func start():
	if started:
		return
	started = true
	bullet_timer.start()
	anim_player.play("Start")
	bullet_timer.wait_time = 5

func _on_BulletTimer_timeout():
	var infected = get_tree().get_nodes_in_group("infected")
	if infected.size() == 0:
		return
	var min_dist = null
	var shoot_dir
	for node in infected:
		if min_dist == null:
			min_dist = node.position.distance_squared_to(position)
			shoot_dir = position.direction_to(node.position)
			continue
		var dist = node.position.distance_squared_to(position)
		if dist < min_dist:
			min_dist = dist
			shoot_dir = position.direction_to(node.position)
	var bullet = Bullet.instance()
	bullet.dir = shoot_dir
	bullet.position = bullet_start_pos.global_position
	owner.add_child(bullet)
