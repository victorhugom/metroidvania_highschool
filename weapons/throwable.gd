class_name Throwable extends RigidBody2D

@export var explosion: PackedScene

var exploded = false

func _ready():
	# Connect to signals if needed
	connect("body_entered", _on_body_entered)

# Optional: Signal handler for entering bodies
func _on_body_entered(body):
	if exploded: return
	
	_create_explosion()

func throw(direction: String, speed:= 400):
	
	if direction == "left":
		speed = -speed
	
	var throw_force = Vector2(speed, -64*3)
	apply_impulse(throw_force, Vector2())
	
func _create_explosion():
	
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = global_position
	var first_node = get_tree().current_scene.get_child(0)
	(first_node as Node2D).add_sibling.call_deferred(new_explosion)
	
	var tween = create_tween() 
	tween.tween_property(self, "modulate:a", 0.0, .05) 
	tween.finished.connect(_on_tween_finished)
	
	exploded = true
	
func _on_tween_finished():
	queue_free()
