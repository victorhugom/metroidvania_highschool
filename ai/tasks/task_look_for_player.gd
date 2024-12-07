extends BTAction

@export var target_player_var: StringName

@export var detection_range = 200
var target_player

func _tick(_delta: float) -> Status:
	
	var enemy = (agent as BaseEnemy)
	
	if enemy.player_in_sight != null:
		blackboard.set_var(target_player_var, enemy.player_in_sight)
		return SUCCESS
	else:
		blackboard.set_var(target_player_var, null)
		return FAILURE
