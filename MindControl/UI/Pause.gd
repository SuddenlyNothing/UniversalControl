extends ColorRect

var paused := false

func pause():
	paused = true
	get_tree().paused = true
	show()

func unpause():
	paused = false
	get_tree().paused = false
	hide()

func _on_Button_pressed():
	unpause()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if paused:
			unpause()
		else:
			pause()
