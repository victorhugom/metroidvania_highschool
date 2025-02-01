extends LimboState

func _enter():
	agent.current_speed = agent.speed

func _update(delta: float):
	agent._perform_move_on_floor(delta)
	
	# Transition to idle if no movement input is detected
	var direction: float = Input.get_axis("player_left", "player_right")
	if direction == 0:
		agent.velocity.x = 0
		agent.main_state_machine.dispatch(agent.to_idle)
	elif agent.velocity.y != 0:
		agent.main_state_machine.dispatch(agent.to_jump)
	else:
		agent.state_changed.emit("walk", agent.velocity)
