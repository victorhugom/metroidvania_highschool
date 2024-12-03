class_name TwoAxisMovement extends CharacterBody2D

signal moving(direction: String, velocity: Vector2)

@onready var health: Health = $Health
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## The base speed
@export var speed: float = 32*2
## The value that will multiply the speed when running
@export var run_multiplier:= 2.5
## The jump speed
@export var  jump_velocity = -400.0
## If false player will not move
@export var can_move:= true

var last_direction:= "left"
var current_speed: float

func  _ready() -> void:
	current_speed = speed

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			var debug_message:= "[color=green][b] %s [/b][/color]: %s"
			
			print_rich(debug_message %["Health",health.current_health])
			print_rich(debug_message %["Speed",current_speed])
			print_rich(debug_message %["Can Move",can_move])
			print_rich(debug_message %["Last Direction",last_direction])
			print_rich(debug_message %["Velocity",velocity])
			print_rich("_______________________________\n")
	if event.is_action_pressed("player_run"):
		current_speed = speed * run_multiplier
	if event.is_action_released("player_run"):
		current_speed = speed

func _physics_process(delta: float) -> void:
	
	if can_move == false:
		return
	
	# Add the gravity.
	apply_gravity(delta)

	# Handle jump.
	if is_on_floor() and Input.is_action_just_pressed("player_jump"):
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		
	if velocity.x > 0:
		last_direction = "right"
	elif velocity.x < 0:
		last_direction = "left"

	move_and_slide()
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
