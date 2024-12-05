extends AnimationPlayer

@onready var player = $".."
@onready var sprite_2d: Sprite2D = $"../Sprite2D"

var combo_index:= 1
var combo_timeout: float = 0
var combo_direction:="right"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.state_changed.connect(_on_state_changed)
	
func _process(delta: float) -> void:
	
	if combo_timeout < 0:
		combo_index = 1
		combo_timeout = 0
	else:
		combo_timeout -= delta

func _on_state_changed(state: String, velocity: Vector2):
	
	if velocity.x < 0:
		sprite_2d.flip_h = true
		combo_direction = "left"
	elif velocity.x > 0:
		combo_direction = "right"
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
			var combo_animation = "attack_0%s_%s" %[combo_index, combo_direction]
			combo_index = 1 if combo_index == 3	 else combo_index + 1
				
			combo_timeout = get_animation(combo_animation).length + .1
			play(combo_animation)	
