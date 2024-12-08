extends BTAction

@export var tagert_node_var: StringName

@export var more_than_distance = 20	
@export var less_than_distance = 20


func _tick(_delta: float) -> Status:
	
	var enemy = (agent as BaseEnemy)
	
	var tagert_node: Node = blackboard.get_var(tagert_node_var)
	var distance = abs(enemy.global_position.distance_to(tagert_node.global_position)) 
	print_debug(distance)
	if distance >= more_than_distance and distance <= less_than_distance:
		return SUCCESS
			
	return FAILURE
	
