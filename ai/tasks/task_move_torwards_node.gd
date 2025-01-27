extends BTAction

@export var target_node_var : StringName = "target_player"
@export var tolerance = 10
@export var run: bool = false

func _tick(_delta: float) -> Status:
	
	var target_node: Node = blackboard.get_var(target_node_var)

	if target_node == null:
		return FAILURE

	var target_position = target_node.global_position
	
	if target_position == null:
		return FAILURE
	
	var target_node_distance = abs(agent.global_position.x - target_position.x)
	
	if target_node_distance < tolerance || agent.has_floor == false:
		(agent as BaseEnemy).stop()
		return SUCCESS
	else:
		(agent as BaseEnemy).move(target_position, run)
		return RUNNING
