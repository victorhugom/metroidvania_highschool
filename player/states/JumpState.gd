extends LimboState

func _enter():
    if agent.is_on_floor():
        agent._perform_jump()

func _update(delta: float):
    agent.state_changed.emit("jump", agent.velocity)
    
    # Transition to idle when landing on the ground
    if agent.is_on_floor():
        agent.main_state_machine.dispatch(agent.to_idle)
        agent.current_jumps = 0
    else:
        agent._perform_move_on_jump(delta)