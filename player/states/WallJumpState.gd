extends LimboState

func _enter():
    if agent.up_direction == Vector2.LEFT:
        agent.rotate(agent.WALL_ROTATION_ANGLE)
    elif agent.up_direction == Vector2.RIGHT:
        agent.rotate(-agent.WALL_ROTATION_ANGLE)
    agent.up_direction = Vector2.UP

func _update(_delta: float):
    if agent.wall_walking_direction != agent.WALL_WALK_DIRECTION.NONE:
        agent._perform_wall_jump(agent.wall_walking_direction)
    
    if agent.wall_walking_direction == agent.WALL_WALK_DIRECTION.LEFT and not agent.shape_cast_2d_left.is_colliding():
        agent.main_state_machine.dispatch(agent.to_jump)
        agent.wall_walking_direction = agent.WALL_WALK_DIRECTION.NONE
    if agent.wall_walking_direction == agent.WALL_WALK_DIRECTION.RIGHT and not agent.shape_cast_2d_right.is_colliding():
        agent.main_state_machine.dispatch(agent.to_jump)
        agent.wall_walking_direction = agent.WALL_WALK_DIRECTION.NONE