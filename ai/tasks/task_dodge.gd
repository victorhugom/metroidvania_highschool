extends BTAction

func _tick(_delta: float) -> Status:
	
	var enemy = (agent as BaseEnemy)
	enemy.dodge()
	return SUCCESS
