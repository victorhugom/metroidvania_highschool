extends LimboState

func _enter():
	if agent.throw_ammunition < 10:
		agent.emit_signal("state_changed", "no_ammo", agent.velocity)
		agent.main_state_machine.dispatch(agent.to_idle)
		return
	agent.is_attacking = true
	agent.emit_signal("state_changed", "hold_throw", agent.velocity)

func _update(_delta: float):
	agent.throw_speed += 10
	if Input.is_action_just_released("player_throw"):
		agent.main_state_machine.dispatch(agent.to_throw_attack)
