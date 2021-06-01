extends KinematicBody2D

onready var sprite := $AnimatedSprite
onready var inf_sprite := $AnimatedSprite2
onready var detect_infected := $DetectInfected

onready var scared_particles := $ScaredParticles
onready var infected_particles := $InfectedParticles

onready var infect := $Infect

onready var hurtbox := $Hurtbox

onready var t := $Tween

export(String, "idle", "scared", "player_control") var start_state := "idle"

var infected_speed := 50.0
var citizen_speed := 30.0

var exit_path

var knockback_force := 150.0
var knockback_velocity := Vector2.ZERO
var knockback_decrease := 0.85

var emitted_infected_particles := false

var last_move := Vector2.ZERO

func _ready():
	$AnimationPlayer.play("Idle")

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)

func get_input():
	var dir = Vector2()
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if dir != Vector2.ZERO:
		set_anim(cartesian_to_isometric(dir))
	return dir.normalized()

func player_move():
	var dir = cartesian_to_isometric(get_input())
	last_move = dir
	move_and_slide(dir * infected_speed)

func set_anim(dir):
	if dir.x < 0:
		sprite.scale.x = -1
		inf_sprite.scale.x = -1
		dir.x = 1
	else:
		sprite.scale.x = 1
		inf_sprite.scale.x = 1
	if dir.x > 0:
		if dir.y > 0:
			sprite.play("DownRight")
			inf_sprite.play("DownRight")
		elif dir.y < 0:
			sprite.play("UpRight")
			inf_sprite.play("UpRight")
		else:
			sprite.play("Right")
			inf_sprite.play("Right")
	else:
		if dir.y > 0:
			sprite.play("Down")
			inf_sprite.play("Down")
		elif dir.y < 0:
			sprite.play("Up")
			inf_sprite.play("Up")
		else:
			sprite.play("Right")
			inf_sprite.play("Right")

func set_infected(infected):
	if infected:
		scared_particles.emitting = false
		add_to_group("infected")
		if is_in_group("citizen"):
			remove_from_group("citizen")
	else:
		if is_in_group("infected"):
			remove_from_group("infected")
		add_to_group("citizen")
	set_infected_collision(infected)
	show_infected_sprite(infected)
	set_hurtbox(infected)

func set_infected_collision(colliding):
	detect_infected.set_collision_layer_bit(2, colliding)

func show_infected_sprite(show):
	if show:
		inf_sprite.show()
		sprite.hide()
	else:
		inf_sprite.hide()
		sprite.show()

func set_hurtbox(is_on):
	hurtbox.set_collision_layer_bit(3, is_on)

func is_overlapping_infected():
	if detect_infected.get_overlapping_areas().size() > 0:
		return true
	return false

func apply_knockback():
	move_and_slide(knockback_velocity)
	knockback_velocity *= knockback_decrease

func set_knockback(normal):
	knockback_velocity = normal*knockback_force

func is_on_void():
	if Global.tilemap == null:
		return false
	var offset_check := Vector2(5, 0)
	var num_checks := 4
	for i in range(num_checks):
		var current_tile = Global.tilemap.world_to_map(position+offset_check)
		if Global.tilemap.get_cellv(current_tile) != -1:
			return false
		offset_check = offset_check.rotated(PI/num_checks*2)
	return true

func is_on_knockback_tile():
	var current_tile = get_current_tile()
	if current_tile == 2 or current_tile == 3:
		return true
	return false

func is_on_finish_tile():
	if get_current_tile() == 3:
		return true
	return false

func get_current_tile():
	return Global.tilemap.get_cellv(Global.tilemap.world_to_map(position))

func fall_in_void():
	t.interpolate_property(self, "position:y", position.y, position.y + 5, 0.5)
	t.interpolate_property(self, "scale", scale, Vector2.ZERO, 0.5)
	t.start()
	yield(t, "tween_all_completed")

func get_shot():
	hide()

func path_to_exit(delta: float):
	if exit_path == null:
		return
	var distance := citizen_speed * delta
	var start_point := position
	for i in range(exit_path.size()):
		var distance_to_next := start_point.distance_to(exit_path[0])
		var dir := position.direction_to(exit_path[0])
		set_anim(dir)
		if distance <= distance_to_next and distance >= 0.0:
			move_and_collide(dir*delta*citizen_speed)
			break
		else:
			move_and_collide(dir*delta*citizen_speed)
		distance -= distance_to_next
		start_point = exit_path[0]
		exit_path.remove(0)

func set_nearest_exit_path():
	if Global.tilemap == null or Global.navigation == null:
		return
	var min_dist = null
	var closest_path = null
	for tile in Global.tilemap.get_used_cells_by_id(3):
		var end_pos = Global.tilemap.map_to_world(tile)
		var path = Global.navigation.get_simple_path(position, end_pos)
		var path_dist := 0.0
		for i in range(1, path.size()):
			path_dist += path[i].distance_to(path[i-1])
		if min_dist == null or path_dist < min_dist:
			min_dist = path_dist
			closest_path = path
	if closest_path == null:
		return
	closest_path[-1] += Vector2(0, 16)
	exit_path = closest_path
	$Node/Line2D.points = exit_path

func no_more_infected():
	if get_tree().get_nodes_in_group("infected").size() <= 1:
		return true
	return false

func lose():
	add_to_group("loser")
	Global.lose()

func start_scared_particles():
	scared_particles.emitting = true

func start_infected_particles():
	if emitted_infected_particles:
		return
	emitted_infected_particles = true
	infected_particles.emitting = true

func check_citizens():
	var citizens = get_tree().get_nodes_in_group("citizen")
	if citizens.size() <= 0:
		owner.win()

func play_infect():
	infect.play()
