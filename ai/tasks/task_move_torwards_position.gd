extends BTAction

@export var tolerance = 10
@export var target_position_var := &"target_position"

func _tick(_delta: float) -> Status:
	
	var target_position: Vector2 = blackboard.get_var(target_position_var)
	
	if target_position == null:
		return FAILURE
	
	var target_node_distance = abs(agent.global_position.x - target_position.x)
	
	if target_node_distance < tolerance || agent.has_floor == false:
		(agent as BaseEnemy).stop()
		return SUCCESS
	else:
		(agent as BaseEnemy).move(target_position)
		return RUNNING
