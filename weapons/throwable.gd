class_name Throwable extends RigidBody2D

@onready var attack_box: AttackBox = $AttackBox
@export var throwable_type: TrowableType = TrowableType.DEFAULT
@onready var throwable_texture: TextureRect = $ThrowableTexture

enum TrowableType {DEFAULT, GLASS, GRANADE}

var explosion: PackedScene
var exploded = false
var direction = "right"
var speed: float = 400

func _ready():
	# Connect to signals if needed
	connect("body_entered", _on_body_entered)
	attack_box.parried.connect(_on_parried)
	attack_box.collision_layer = collision_layer
	attack_box.collision_mask = collision_mask

	match throwable_type:
		TrowableType.GLASS:
			attack_box.damage = 0
			explosion = preload("res://weapons/acid_bottle_explosion.tscn")
			throwable_texture.texture = preload("res://assets/props/itens/throwable_bottle.png")
		TrowableType.GRANADE:
			attack_box.damage = 2
			explosion = preload("res://weapons/granade_explosion.tscn")
			throwable_texture.texture = preload("res://assets/props/itens/throwable_granade.png")
		TrowableType.DEFAULT:
			attack_box.damage = 1
			explosion = null
			throwable_texture.texture = preload("res://assets/props/itens/throwable_baseball.png")
	
# Optional: Signal handler for entering bodies
func _on_body_entered(_body):
	if exploded: return
	
	_create_explosion()

func _on_parried(_character: CharacterBody2D):
	speed = -(speed / 2)
	
	var throw_force = Vector2(speed, -64 * 3)
	apply_impulse(throw_force, Vector2())

func throw(_direction: String, _speed := 400):
	
	direction = _direction
	speed = _speed
	
	if direction == "left":
		speed = -speed
	
	var throw_force = Vector2(speed, -64 * 3)
	apply_impulse(throw_force, Vector2())
	
func _create_explosion():
	
	if explosion:
		var new_explosion = explosion.instantiate()
		new_explosion.global_position = global_position
		var first_node = get_tree().current_scene.get_child(0)
		(first_node as Node2D).add_sibling.call_deferred(new_explosion)
		
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, .05)
		tween.finished.connect(_on_tween_finished)
		
		exploded = true
	else:
		var tween = create_tween()
		tween.tween_callback(_on_tween_finished).set_delay(.05)
	
func _on_tween_finished():
	queue_free()
