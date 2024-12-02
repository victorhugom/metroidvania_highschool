extends BTAction

@export var target_player_var: StringName = &"target_player"
@export var dir_var := &"dir"

@export var detection_range = 200
var target_player

func _tick(_delta: float) -> Status:
	
	var dir = blackboard.get_var(dir_var)
	
	var space_state = (agent as Enemy).get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = (agent as Enemy).global_position
	query.to = (agent as Enemy).global_position + Vector2(dir * detection_range, 0)
	query.collision_mask = 1  # Adjust this according to your layers

	var result = space_state.intersect_ray(query)
	
	if result and result.collider.is_in_group("player"):
		target_player = result.collider
		blackboard.set_var(target_player_var, target_player)
		return SUCCESS
	else:
		blackboard.set_var(target_player_var, null)
		return FAILURE
