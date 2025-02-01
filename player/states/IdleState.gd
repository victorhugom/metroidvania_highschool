extends LimboState

func _enter():
	agent.emit_signal("state_changed", "idle", agent.velocity)

func _update(delta: float):
	# Transition to walk if movement input is detected
	var direction: float = Input.get_axis("player_left", "player_right")
	if direction != 0:
		agent.main_state_machine.dispatch(agent.to_walk)
