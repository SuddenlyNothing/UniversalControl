extends Camera2D

export(int) var speed = 100

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)

func _process(delta):
	var dir = Vector2()
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	dir = cartesian_to_isometric(dir)
	position += dir.normalized() * speed * delta
