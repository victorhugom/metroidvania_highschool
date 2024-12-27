extends Node2D
const THROWABLE = preload("res://weapons/throwable.tscn")

@onready var timer: Timer = $Timer

@export var direction: String = "left"
@export var speed: int = 400
@export var angle: int = 45

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(throw)

func throw():
	var new_projectile: Throwable = THROWABLE.instantiate()
	new_projectile.global_position = Vector2(global_position.x, global_position.y - 32)
	new_projectile.explosion = load("res://weapons/acid.tscn")
	
	new_projectile.throw(direction, speed)

	var first_node = get_tree().current_scene.get_child(0)
	(first_node as Node2D).add_sibling(new_projectile)
