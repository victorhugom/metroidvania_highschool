extends AnimationPlayer

@onready var player = $".."

var last_direction = "left"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.moving.connect(_on_moving)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_attack"):
		play("attack_" + last_direction)
		player.can_move = false

func _on_moving(direction: String, velocity: Vector2):
	
	last_direction = direction
	
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


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack_"):
		player.can_move = true
