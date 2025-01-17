class_name Throwable extends RigidBody2D

@export var explosion: PackedScene

@onready var attack_box: AttackBox = $AttackBox

var exploded = false
var direction = "right"
var speed = 400

func _ready():
	# Connect to signals if needed
	connect("body_entered", _on_body_entered)
	attack_box.parried.connect(_on_parried)
	attack_box.collision_layer = collision_layer
	attack_box.collision_mask = collision_mask
	
# Optional: Signal handler for entering bodies
func _on_body_entered(_body):
	if exploded: return
	
	_create_explosion()

func _on_parried(_character: CharacterBody2D):
	speed = -int(speed/2)
	
	var throw_force = Vector2(speed, -64*3)
	apply_impulse(throw_force, Vector2())

func throw(_direction: String, _speed:= 400):
	
	direction = _direction
	speed = _speed
	
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
