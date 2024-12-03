class_name Player extends CharacterBody2D

signal moving(direction: String, velocity: Vector2)

@onready var health: Health = $Health
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## The base speed
@export var speed: float = 64
## The value that will multiply the speed when running
@export var run_multiplier:= 2.5
## The max height that the player can jump
@export var jump_height = 128
## If false player will not move
@export var can_move:= true

var last_direction:= "left"
var current_speed: float
var acceleration:= 10 
var deceleration:= 50 
var jump_velocity:= -256

func  _ready() -> void:
	var gravity = get_gravity().y
	jump_velocity = -sqrt(2 * gravity * jump_height)
	
	current_speed = speed

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			DebugUI.ON = not DebugUI.ON
			
	if event.is_action_pressed("player_run"):
		current_speed = speed * run_multiplier
	if event.is_action_released("player_run"):
		current_speed = speed
		
func _process(delta: float) -> void:
	if DebugUI.ON:
		var debug_message_template:= "[color=green][b] %s [/b][/color]: %s \n"
		var debug_message:= ""

		debug_message +=debug_message_template %["Health",health.current_health]
		debug_message +=debug_message_template %["Speed",current_speed]
		debug_message +=debug_message_template %["Can Move",can_move]
		debug_message +=debug_message_template %["Last Direction",last_direction]
		debug_message +=debug_message_template %["Velocity",velocity]
		debug_message +="_______________________________\n"

		DebugUI.show_message(debug_message)

func _physics_process(delta: float) -> void:
	
	if can_move == false:
		return
	
	# Handle jump.
	if is_on_floor() and Input.is_action_just_pressed("player_jump"):
		velocity.y = jump_velocity
		
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("player_left", "player_right")
	
	if velocity.y == 0:
		if direction:
			velocity = velocity.lerp(Vector2(direction, 0) * current_speed, acceleration * delta)
		else:
			velocity = velocity.lerp(Vector2(direction, 0) * current_speed, deceleration * delta)
	else:
		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
	
	apply_gravity(delta)
	move_and_slide()

	if velocity.x > 0:
		last_direction = "right"
	elif velocity.x < 0:
		last_direction = "left"
		

	if is_on_floor():
		moving.emit(last_direction, velocity)
	else:
		if velocity.y < 0: 
			moving.emit("up_" + last_direction, velocity)
		elif velocity.y > 0: 
			moving.emit("down_" + last_direction, velocity)

func apply_gravity(delta):
	
	if not is_on_floor():
		if velocity.y < 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 1.2
