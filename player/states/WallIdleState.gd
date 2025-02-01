extends LimboState

func _enter():
    agent.emit_signal("state_changed", "wall_idle", agent.velocity)

func _update(_delta: float):
    if int(agent.velocity.y) != 0:
        if agent.up_direction == Vector2.LEFT:
            agent.main_state_machine.dispatch(agent.to_walk_wall_right)
        else:
            agent.main_state_machine.dispatch(agent.to_walk_wall_left)