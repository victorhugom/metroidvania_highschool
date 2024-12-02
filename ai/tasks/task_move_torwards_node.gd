extends BTAction

@export var target_node_var := &"target_node"
@export var target_node_distance_var := &"target_node_distance"
@export var dir_var := &"dir"

@export var speed = 100
@export var tolerance = 10


func _tick(_delta: float) -> Status:
	
	var target_node: Node = blackboard.get_var(target_node_var)
	
	if target_node == null:
		return FAILURE
	
	var target_pos = target_node.global_position
	var dir = blackboard.get_var(dir_var)
	
	var target_node_distance = abs(agent.global_position.x - target_pos.x)
	blackboard.set_var(target_node_distance_var, target_node_distance)
	
	if target_node_distance < tolerance:
		(agent as Enemy).move(dir, 0)
		return SUCCESS
	else:
		(agent as Enemy).move(dir, speed)
		return RUNNING
