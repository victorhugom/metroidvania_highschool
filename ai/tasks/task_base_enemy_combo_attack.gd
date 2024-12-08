extends BTAction

func _tick(_delta: float) -> Status:
	
	var enemy = (agent as BaseEnemy)
	enemy.combo_attack()
	return SUCCESS
