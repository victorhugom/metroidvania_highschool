extends AnimationPlayer

@onready var player = $".."
@onready var sprite_2d: Sprite2D = $"../Sprite2D"

var combo_index:= 1
var combo_timeout: float = 0
var player_direction:="right"

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
		player_direction = "left"
	elif velocity.x > 0:
		player_direction = "right"
		sprite_2d.flip_h = false

	if state == "idle":
		play("idle")
	elif state == "walk":
		play("walk")
	elif state == "run":
		play("run")
	elif state == "dash":
		play("dash")
	elif state == "jump":
		# JUMP UP
		if velocity.y > 0:
			play("down")
		# FALLING DOWN
		elif velocity.y < 0:
			play("up")
	elif state == "attack":
		if velocity.y != 0:
			play("attack_01_%s" %player_direction, -1, 2)
		else:
			var combo_animation = "attack_0%s_%s" %[combo_index, player_direction]
			combo_index = 1 if combo_index == 5	 else combo_index + 1
				
			combo_timeout = get_animation(combo_animation).length + .1
			play(combo_animation)
	elif state == "secondary_attack":
		var secondary_attack_animation = "secondary_attack_%s" %player_direction
		play(secondary_attack_animation)
	elif state == "parry":
		var secondary_attack_animation = "parry_%s" %player_direction
		play(secondary_attack_animation)
