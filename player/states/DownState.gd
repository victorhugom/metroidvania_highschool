extends LimboState

func _enter():
    if agent.is_on_floor():
        agent.set_collision_mask_value(agent.COLLISION_LAYER_ONE_WAY, false)
        agent.collision_down_timeout = agent.collision_down_duration

func _update(delta: float):
    agent.collision_down_timeout -= delta
    if agent.collision_down_timeout <= 0:
        agent.set_collision_mask_value(agent.COLLISION_LAYER_ONE_WAY, true)
        agent.main_state_machine.dispatch(agent.to_jump)