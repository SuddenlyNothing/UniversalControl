extends ParallaxBackground

var scroll_speed := Vector2(3, 5)

func _process(delta):
	$ParallaxLayer2.motion_offset += scroll_speed*delta
	$ParallaxLayer3.motion_offset += scroll_speed/3*2*delta
	$ParallaxLayer4.motion_offset += scroll_speed/3*delta
	var dir := Vector2()
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	$Camera2D.position += dir*500*delta
