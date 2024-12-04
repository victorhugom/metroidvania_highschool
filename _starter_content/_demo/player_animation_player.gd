extends AnimationPlayer

@onready var player = $".."
@onready var sprite_2d: Sprite2D = $"../Sprite2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.state_changed.connect(_on_state_changed)

func _on_state_changed(state: String, velocity: Vector2):
	
	if velocity.x < 0:
		sprite_2d.flip_h = true
	elif velocity.x > 0:
		sprite_2d.flip_h = false

	if state == "idle":
		play("idle")
	elif state == "walk":
		play("walk")
	elif state == "jump":
		# JUMP UP
		if velocity.y > 0:
			play("up")
		# FALLING DOWN
		elif velocity.y < 0:
			play("down")
	elif state == "attack":
		if velocity.y != 0:
			play("attack", -1, 2)
		else:
			play("attack")
