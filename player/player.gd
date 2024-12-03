class_name Player extends CharacterBody2D

signal state_changed(current_state: String, velocity: Vector2)

@onready var health: Health = $Health
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## The base speed
@export var speed: float = 64
## The max height that the player can jump
@export var jump_height = 64
## The value that will multiply the speed when running
@export var run_multiplier:= 2.5
@export var acceleration:= 10 
@export var deceleration:= 50
## If false player will not move
@export var can_move:= true

var last_direction:= "left"
var current_speed: float
var jump_velocity: float

var main_state_machine: LimboHSM
var to_idle: StringName = &"state_ended"
var to_jump: StringName = &"to_jump"
var to_walk: StringName = &"to_walk"
var to_attack: StringName = &"to_attack"

func  _ready() -> void:
	current_speed = speed
	animation_player.animation_finished.connect(_on_animation_finished)
	_initiate_state_machine()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			DebugUI.ON = not DebugUI.ON
			
	if event.is_action_pressed("player_run"):
		current_speed = speed * run_multiplier
	if event.is_action_released("player_run"):
		current_speed = speed
	if event.is_action_pressed("player_jump") and is_on_floor():
		main_state_machine.dispatch(to_jump)
	if event.is_action_pressed("player_attack"):
		main_state_machine.dispatch(to_attack)
		
func _process(_delta: float) -> void:
	if DebugUI.ON:
		var debug_message_template:= "[color=green][b] %s [/b][/color]: %s \n"
		var debug_message:= ""

		debug_message +=debug_message_template %["Health",health.current_health]
		debug_message +=debug_message_template %["Speed",current_speed]
		debug_message +=debug_message_template %["Can Move",can_move]
		debug_message +=debug_message_template %["Last Direction",last_direction]
		debug_message +=debug_message_template %["Velocity",velocity]
		
		var current_state = ""
		if main_state_machine != null:
			current_state = main_state_machine.get_active_state().name
		debug_message +=debug_message_template %["Current State", current_state]
		debug_message +="_______________________________\n"

		DebugUI.show_message(debug_message)

func _physics_process(delta: float) -> void:
	
	if can_move == false:
		return
	
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
	
	_apply_gravity(delta)
	move_and_slide()

	if velocity.x > 0:
		last_direction = "right"
	elif velocity.x < 0:
		last_direction = "left"

func _apply_gravity(delta):
	
	if not is_on_floor():
		if velocity.y < 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 1.2

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack_"):
		main_state_machine.dispatch(to_idle)
		can_move = true

func _initiate_state_machine():
	main_state_machine = LimboHSM.new()
	add_child(main_state_machine)
	
	var state_idle = LimboState.new().named("idle").call_on_enter(_state_idle_enter).call_on_update(_state_idle_update)
	var state_walk = LimboState.new().named("walk").call_on_enter(_state_walk_enter).call_on_update(_state_walk_update)
	var state_jump = LimboState.new().named("jump").call_on_enter(_state_jump_enter).call_on_update(_state_jump_update)
	var state_attack = LimboState.new().named("attack").call_on_enter(_state_attack_enter).call_on_update(_state_attack_update)
	
	main_state_machine.add_child(state_idle)
	main_state_machine.add_child(state_walk)
	main_state_machine.add_child(state_jump)
	main_state_machine.add_child(state_attack)
	
	main_state_machine.initial_state = state_idle
	
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_idle, to_idle)
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_attack, to_attack)	
	
	main_state_machine.add_transition(state_idle, state_walk, to_walk)
	
	main_state_machine.add_transition(state_idle, state_jump, to_jump)
	main_state_machine.add_transition(state_walk, state_jump, to_jump)
	
	main_state_machine.initialize(self)
	main_state_machine.set_active(true)
	
func _state_idle_enter():
	state_changed.emit("idle", velocity)
	
func _state_idle_update(_delta:float):
	state_changed.emit("idle", velocity)
	if velocity.x != 0:
		main_state_machine.dispatch(to_walk)

func _state_walk_enter():
	state_changed.emit("walk", velocity)
	
func _state_walk_update(_delta:float):
	state_changed.emit("walk", velocity)
	if velocity.x == 0:
		main_state_machine.dispatch(&"state_ended")
	
func _state_jump_enter():
	state_changed.emit("jump", velocity)
	
	var gravity = get_gravity().y
	jump_velocity = -sqrt(2 * gravity * jump_height)
	velocity.y = jump_velocity

func _state_jump_update(_delta:float):
	state_changed.emit("jump", velocity)
	if is_on_floor():
		main_state_machine.dispatch(to_idle)
	
func _state_attack_enter():
	state_changed.emit("attack", velocity)
	can_move = false
	
func _state_attack_update(_delta:float):
	state_changed.emit("attack", velocity)
