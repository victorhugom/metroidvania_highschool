extends LimboState

func _enter():
    agent.rotate(agent.WALL_ROTATION_ANGLE)
    agent.current_speed = agent.speed * agent.wall_walk_multiplier
    agent.wall_walking_direction = agent.WALL_WALK_DIRECTION.LEFT
    agent.up_direction = Vector2.RIGHT

func _update(delta: float):
    if not agent.is_on_floor():
        agent.velocity += Vector2(-agent.get_gravity().y, 0) * delta * 5
    
    agent._perform_move_on_wall_left(delta)
    
    if int(agent.velocity.y) == 0:
        agent.main_state_machine.dispatch(agent.to_wall_idle)
        agent.emit_signal("state_changed", "wall_idle", agent.velocity)
    else:
        agent.emit_signal("state_changed", "walk_wall_left", agent.velocity)