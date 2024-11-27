extends AnimationPlayer

@onready var player = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.moving.connect(_on_moving)

func _on_moving(direction: String, velocity: Vector2):
	
	if velocity.length() == 0:
		play("idle")
	elif direction == "left" and has_animation("walk_left"):
		play("walk_left")
	elif direction == "right" and has_animation("walk_right"):
		play("walk_right")
	elif direction == "up_left" and has_animation("up_left"):
		play("up_left")
	elif direction == "up_right" and has_animation("up_right"):
		play("up_right")
	elif direction == "down_left" and has_animation("down_left"):
		play("down_left")
	elif direction == "down_right" and has_animation("down_right"):
		play("down_right")
