extends StateMachine

func _ready():
	add_state("idle")
	add_state("scared")
	add_state("player_control")
	add_state("knockback")
	add_state("fall")
	add_state("shot")
	call_deferred("set_state", parent.start_state)

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.scared:
			parent.path_to_exit(delta)
			if parent.is_on_finish_tile():
				parent.lose()
		states.player_control:
			parent.player_move()
		states.fall:
			pass
		states.knockback:
			parent.apply_knockback()
		states.shot:
			pass

func _get_transition(delta):
	match state:
		states.idle:
			if parent.is_overlapping_infected():
				return states.player_control
			if Global.alerted:
				print(Global.alerted)
				return states.scared
		states.scared:
			if parent.is_overlapping_infected():
				return states.player_control
		states.player_control:
			if parent.is_on_knockback_tile():
				return states.knockback
			if parent.is_on_void():
				return states.fall
		states.fall:
			pass
		states.knockback:
			if parent.knockback_velocity.length() <= 5:
				return states.player_control
		states.shot:
			pass
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.set_infected(false)
		states.scared:
			parent.start_scared_particles()
			parent.set_nearest_exit_path()
			parent.set_infected(false)
		states.player_control:
			parent.start_infected_particles()
			parent.set_infected(true)
			if previous_state != null and previous_state != states.knockback:
				parent.check_citizens()
				parent.play_infect()
		states.fall:
			parent.fall_in_void()
			parent.lose()
		states.knockback:
			parent.set_knockback(-parent.last_move)
			parent.set_infected(true)
		states.shot:
			parent.get_shot()
			parent.lose()

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			pass
		states.scared:
			pass
		states.player_control:
			pass
		states.fall:
			pass
		states.knockback:
			pass
		states.shot:
			pass

func _on_Hurtbox_area_entered(area):
	set_state(states.shot)
