extends Node2D

@onready var timer: Timer = $Timer

@export var damage: int = 2
@export var duration: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = duration
	timer.timeout.connect(_destroy)
	
func _destroy():
	queue_free()
