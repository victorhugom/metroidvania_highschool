extends LimboState

func _enter():
	if agent.is_attacking:
		return
	agent.is_attacking = true
	agent.emit_signal("state_changed", "jump_attack", agent.velocity)

func _update(_delta: float):
	if agent.animation_player.current_animation.begins_with("jump_attack_") == false:
		if agent.is_on_floor():
			agent.main_state_machine.dispatch(agent.to_idle)
		else:
			agent.main_state_machine.dispatch(agent.to_jump)

func _exit():
	agent.is_attacking = false
