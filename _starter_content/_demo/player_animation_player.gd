extends AnimationPlayer

@onready var player = $".."

var last_direction = "left"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.state_changed.connect(_on_state_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_attack"):
		play("attack_" + last_direction)
		player.can_move = false

func _on_state_changed(state: String, velocity: Vector2):
	
	#IDLE
	if state == "idle":
		play("idle")
	#WALK
	elif state == "walk":
		if velocity.x < 0 and has_animation("walk_left"):
			last_direction = "left"
			play("walk_left")
		elif velocity.x > 0 and has_animation("walk_right"):
			last_direction = "right"
			play("walk_right")
	#JUMP
	elif state == "jump":
		# JUMP UP
		if velocity.y > 0:
			if velocity.x < 0 and has_animation("up_left"):
				last_direction = "left"
				play("up_left")
			elif velocity.x > 0 and has_animation("up_right"):
				last_direction = "right"
				play("up_right")
		# FALLING DOWN
		elif velocity.y < 0:
			if velocity.x < 0 and has_animation("down_left"):
				last_direction = "left"
				play("down_left")
			elif velocity.x > 0 and has_animation("down_right"):
				last_direction = "right"
				play("down_right")
	elif state == "attack":
		play("attack_" + last_direction)
