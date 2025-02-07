extends BTAction

var delay: float = 0

func _tick(delta: float) -> Status:
	
	delay += delta
	var enemy = (agent as BaseEnemy)
	
	if delay > 2:
	
		var throwables = enemy.get_tree().get_nodes_in_group("boss_throwable")
		
		for t: AutoThrowable in throwables:
			t.throw()
			
		delta = 0
		
		return SUCCESS
		
	enemy.animation_player.play("hold_attack")
	return RUNNING
	
