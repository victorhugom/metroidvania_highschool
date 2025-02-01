extends LimboState

func _enter():
    agent.emit_signal("state_changed", "shade", agent.velocity)

func _update(_delta: float):
    if agent.animation_player.current_animation.begins_with("sahde") == false:
        agent.main_state_machine.dispatch(agent.to_idle)