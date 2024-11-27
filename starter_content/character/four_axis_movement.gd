class_name FourAxisMovement extends CharacterBody2D

signal moving(direction: String, velocity: Vector2)

@onready var health: Health = $Health

## The base speed
@export var speed: float = 32*2
## The value that will multiply the speed when running
@export var run_multiplier:= 2.5
## If false player will not move
@export var can_move:= true

var last_anim_direction = "idle"
var current_speed: float

func _ready() -> void:
	current_speed = speed
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			var debug_message:= "[color=green][b] %s [/b][/color]: %s"
			
			print_rich(debug_message %["Health",health.current_health])
			print_rich(debug_message %["Speed",speed])
			print_rich(debug_message %["Can Move",can_move])
			print_rich(debug_message %["Last Anim Direction",last_anim_direction])
			print_rich(debug_message %["Velocity",velocity])
			print_rich("_______________________________\n")
		if event.is_action_pressed("ui_run"):
			current_speed = speed * run_multiplier
		if event.is_action_released("ui_run"):
			current_speed = speed
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if can_move == false:
		return
	
	var move_direction_vector = Input.get_vector( "ui_left", "ui_right", "ui_up","ui_down")
	velocity = move_direction_vector * current_speed

	var direction = last_anim_direction
	
	if velocity.length() > 0: #idle
		
		var angle = atan2(velocity.y, velocity.x) # angle in [-PI, PI]
		if abs(angle) < 0.25 * PI:
			direction = "right"
		elif abs(angle) > 0.75 * PI:
			direction = "left"
		elif angle > 0.0:
			direction = "down"
		else:
			direction = "up"

	last_anim_direction = direction
	moving.emit(direction, velocity)
	
	move_and_slide()
