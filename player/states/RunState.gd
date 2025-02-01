extends LimboState

func _enter():
	agent.current_speed = agent.speed * agent.run_multiplier

func _update(delta: float):
	agent._perform_move_on_floor(delta)
	
	# Transition to walk or idle when run input is released
	var direction: float = Input.get_axis("player_left", "player_right")
	if direction == 0:
		agent.velocity.x = 0
		agent.main_state_machine.dispatch(agent.to_idle)
	elif not Input.is_action_pressed("player_run"):
		agent.main_state_machine.dispatch(agent.to_walk)
	elif agent.velocity.y != 0:
		agent.main_state_machine.dispatch(agent.to_jump)
	else:
		agent.state_changed.emit("run", agent.velocity)
