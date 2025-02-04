extends Node2D
const THROWABLE = preload("res://weapons/throwable.tscn")

@onready var timer: Timer = $Timer
@onready var throw_position: Marker2D = $ThrowPosition

@export var direction: String = "left"
@export var speed: int = 800
@export var angle: int = 45

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(throw)

func throw():
	var new_projectile: Throwable = THROWABLE.instantiate()
	new_projectile.global_position = throw_position.global_position
	new_projectile.throwable_type = Throwable.TrowableType.DEFAULT
	
	new_projectile.throw(direction, speed)

	var first_node = get_tree().current_scene.get_child(0)
	(first_node as Node2D).add_sibling(new_projectile)
