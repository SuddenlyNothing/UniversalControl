extends ColorRect

signal faded_in
signal faded_out

onready var t_in := $fade_in
onready var t_out := $fade_out

func fade_in():
	t_in.interpolate_property(self, "modulate:a", 1, 0, 0.5)
	t_in.start()
	yield(t_in, "tween_all_completed")
	emit_signal("faded_in")

func fade_out():
	t_out.interpolate_property(self, "modulate:a", 0, 1, 0.5)
	t_out.start()
	yield(t_out, "tween_all_completed")
	emit_signal("faded_out")
