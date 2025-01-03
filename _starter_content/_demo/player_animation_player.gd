extends AnimationPlayer

@onready var player = $".."
@onready var sprite_2d: Sprite2D = $"../Sprite2D"

var combo_index:= 1
var combo_timeout: float = 0
var player_direction:="right"
var previous_state: String

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
	
	if state == "walk_wall_right":
		sprite_2d.flip_h = false
		if velocity.y < 0:
			player_direction = "up"
		elif velocity.y > 0:
			player_direction = "down"
	elif state == "walk_wall_left":
		sprite_2d.flip_h = true
		if velocity.y < 0:
			player_direction = "up"
		elif velocity.y > 0:
			player_direction = "down"
	else:
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
	elif state == "walk_wall_left":
		if previous_state != state:
			play("wall_idle_end")
			queue("wall_" + player_direction)
	elif state == "walk_wall_right":
		if previous_state != state:
			play("wall_idle_end")
			queue("wall_" + player_direction)
	if state == "wall_idle":
		if previous_state != state:
			play("wall_idle_start")
			queue("wall_idle")
	elif state == "run":
		play("run")
	elif state == "dash":
		play("dash")
	elif state == "dash_attack":
		play("dash_attack")
	elif state == "jump":
		# JUMP UP
		if velocity.y > 0:
			play("down")
		# FALLING DOWN
		elif velocity.y < 0:
			play("up")
	elif state == "holding_attack":
		play("hold_attack")
	elif state == "strong_attack":
		play("strong_attack")
	elif state == "attack":
		if velocity.y != 0:
			play("attack_01_%s" %player_direction, -1, 2)
		else:
			var combo_animation = "attack_0%s_%s" %[combo_index, player_direction]
			combo_index = 1 if combo_index == 5	 else combo_index + 1
			combo_timeout = get_animation(combo_animation).length + .5
			play(combo_animation)
	elif state == "jump_attack":
		play("jump_attack_%s" %player_direction)
	elif state == "hold_throw":
		play("hold_throw_" + player_direction)
	elif state == "throw":
		play("throw_" + player_direction)
	elif state == "parry":
		play("parry_%s" %player_direction)
	elif state == "shade":
		play("shade", -1, 1.5)
		
	previous_state = state
