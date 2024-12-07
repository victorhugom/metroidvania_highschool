extends Area2D

var knockback_force = 2000

func _on_area_entered(area: Area2D) -> void:
	apply_knockback(area)

func _on_body_entered(body: Node2D) -> void:
	apply_knockback(body)
		
func apply_knockback(attacker):
	var knockback_direction = (attacker.global_position - global_position).normalized()
	knockback_direction.y = -0.1 # Adjust the vertical direction of knockback if needed
	attacker.velocity = knockback_direction * knockback_force
