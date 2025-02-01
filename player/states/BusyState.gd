extends LimboState

func _enter():
	agent.velocity = Vector2.ZERO
	agent.emit_signal("state_changed", "busy", agent.velocity)

func _update(_delta: float):
	if not agent.is_busy:
		agent.main_state_machine.dispatch(agent.to_idle)
