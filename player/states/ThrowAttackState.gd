extends LimboState

# Preload resources
const THROWABLE = preload("res://weapons/throwable.tscn")

func _enter():
	var new_projectile: Throwable = THROWABLE.instantiate()
	new_projectile.global_position = agent.throw_hand.global_position
	new_projectile.throwable_type = agent.throwable_type
	
	new_projectile.throw(agent.last_direction, agent.throw_speed)

	var first_node = get_tree().current_scene.get_child(0)
	(first_node as Node2D).add_sibling(new_projectile)
	agent.state_changed.emit("throw", agent.velocity)

func _update(_delta: float):
	if agent.animation_player.current_animation.begins_with("throw_") == false :
		agent.is_attacking = false
		agent.throw_speed = agent.MIN_THROW_SPEED    
		agent.main_state_machine.dispatch(agent.to_idle)
		agent.throw_ammunition -= 10

func _exit():
	pass
