extends BTAction

func _tick(_delta: float) -> Status:
	
	var enemy = (agent as BaseEnemy)
	if enemy.is_attacking:
		return RUNNING
	else:
		enemy.swing_bat()
		return SUCCESS
	
