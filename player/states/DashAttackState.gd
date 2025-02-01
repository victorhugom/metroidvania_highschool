extends LimboState

func _enter():
	agent.is_dashing = true
	agent.emit_signal("state_changed", "dash_attack", agent.velocity)

func _update(delta: float):
	if agent.animation_player.current_animation != "dash_attack":
		agent.is_dashing = false
		agent.main_state_machine.dispatch(agent.to_idle)
