extends BTAction

@export var roam_min_radius: float = 128
@export var roam_max_radius: float = 256
@export var roam_position_var: StringName = &"roam_position"

func _tick(_delta: float) -> Status:
	
	var origin_position = (agent as BaseEnemy).origin_position
	var random_point = origin_position
	while origin_position.distance_to(random_point) < roam_min_radius:
		random_point = origin_position + Vector2(randf() * roam_max_radius - roam_max_radius / 2, origin_position.y)

	blackboard.set_var(roam_position_var, random_point)
	return SUCCESS
