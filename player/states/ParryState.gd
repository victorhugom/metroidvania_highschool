extends LimboState

func _enter():
    agent.is_parrying = true
    agent.emit_signal("state_changed", "parry", agent.velocity)

func _update(_delta: float):
    if agent.animation_player.current_animation.begins_with("parry_") == false:
        agent.main_state_machine.dispatch(agent.to_idle)

func _exit():
    agent.is_parrying = false