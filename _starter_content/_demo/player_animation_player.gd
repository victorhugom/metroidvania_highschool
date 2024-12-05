extends AnimationPlayer

@onready var player = $".."
@onready var sprite_2d: Sprite2D = $"../Sprite2D"

var combo_index = 1
var combo_timeout = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.state_changed.connect(_on_state_changed)
	
func _process(delta: float) -> void:
	
	if combo_timeout < 0:
		combo_index = 1
		combo_timeout = 0
	elif combo_timeout > 0:
		combo_timeout -= delta

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
			var combo_direction = "left" if velocity.x < 0 else "right"
			var combo_animation = "attack_0%s_%s" %[combo_index, combo_direction]
			if combo_index == 3:
				combo_index = 1
			else:
				combo_index += 1
				
			combo_timeout = get_animation(combo_animation).length + .5
			play(combo_animation)	
