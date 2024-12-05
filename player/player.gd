class_name Player extends CharacterBody2D

signal state_changed(current_state: String, velocity: Vector2)

@onready var health: Health = $Health
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_box: AttackBox = $AttackBox
@onready var attack_collision_shape_2d: CollisionShape2D = $AttackBox/CollisionShape2D

## The base speed
@export var speed: float = 64
## The max height that the player can jump
@export var jump_height = 64
## The jump buffer time in seconds, used to allow player to make mistakes when jumping
@export var jump_buffer_time = 0.1 # Buffer time in seconds

## The value that will multiply the speed when running
@export var run_multiplier:= 2.5
@export var acceleration:= 10 
@export var deceleration:= 50
## If false player will not move

var is_attacking:= false
var current_speed: float

# jump
var jump_velocity: float
var jump_buffer = false 
var current_jump_buffer_timer = 0.0

var dash_speed = 600.0 
var dash_cooldown = 0.5
var dash_duration = 0.2

# dash variables 
var is_dashing = false 
var current_dash_duration = 0.0
var current_dash_cooldown = 0.0

# state machine
var main_state_machine: LimboHSM
var to_idle: StringName = &"state_ended"
var to_jump: StringName = &"to_jump"
var to_walk: StringName = &"to_walk"
var to_run: StringName = &"to_run"
var to_attack: StringName = &"to_attack"
var to_dash: StringName = &"to_dash"

func  _ready() -> void:
	current_speed = speed
	animation_player.animation_finished.connect(_on_animation_finished)
	_initiate_state_machine()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			DebugUI.ON = not DebugUI.ON
	if event.is_action_pressed("player_run"):
		main_state_machine.dispatch(to_run)
	if event.is_action_released("player_run"):
		main_state_machine.dispatch(to_idle)
	if event.is_action_pressed("player_jump"):
		if is_on_floor(): 
			main_state_machine.dispatch(to_jump)
		else: # Set the jump buffer 
			jump_buffer = true 
			current_jump_buffer_timer = jump_buffer_time
	if event.is_action_pressed("player_attack"):
		main_state_machine.dispatch(to_attack)
	if event.is_action_pressed("player_dash"):
		main_state_machine.dispatch(to_dash)

func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("player_run"):
		main_state_machine.dispatch(to_run)
	
	if DebugUI.ON:
		var debug_message_template:= "[color=green][b] %s [/b][/color]: %s \n"
		var debug_message:= ""

		debug_message +=debug_message_template %["Health",health.current_health]
		debug_message +=debug_message_template %["Speed",current_speed]
		debug_message +=debug_message_template %["Can Move",_can_move()]
		debug_message +=debug_message_template %["Last Direction",velocity.x]
		debug_message +=debug_message_template %["Velocity",velocity]
		debug_message +=debug_message_template %["Jump Buffer Active:", jump_buffer]
		debug_message +=debug_message_template %["Jump Buffer Timer", current_jump_buffer_timer]
		
		var current_state = ""
		if main_state_machine != null:
			current_state = main_state_machine.get_active_state().name
		debug_message +=debug_message_template %["Current State", current_state]
		debug_message +="_______________________________\n"

		DebugUI.show_message(debug_message)

func _physics_process(delta: float) -> void:
	
	if _can_move() == false and is_on_floor():
		velocity.x = 0
		
	_apply_gravity(delta)
	_handle_jump_buffer(delta)
	current_dash_cooldown-= delta
	
	move_and_slide()
	
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

func _apply_gravity(delta):
	
	if not is_on_floor():
		if velocity.y < 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 1.2

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		if is_on_floor():
			main_state_machine.dispatch(to_idle)
		else:
			main_state_machine.dispatch(to_jump)

func _initiate_state_machine():
	main_state_machine = LimboHSM.new()
	add_child(main_state_machine)
	
	var state_idle = LimboState.new().named("idle").call_on_enter(_state_idle_enter).call_on_update(_state_idle_update)
	var state_walk = LimboState.new().named("walk").call_on_enter(_state_walk_enter).call_on_update(_state_walk_update)
	var state_run = LimboState.new().named("run").call_on_enter(_state_run_enter).call_on_update(_state_run_update)
	var state_jump = LimboState.new().named("jump").call_on_enter(_state_jump_enter).call_on_update(_state_jump_update)
	var state_dash = LimboState.new().named("dash").call_on_enter(_state_dash_enter).call_on_update(_state_dash_update)
	var state_attack = LimboState.new().named("attack").call_on_enter(_state_attack_enter).call_on_update(_state_attack_update).call_on_exit(_state_attack_exit)
	
	main_state_machine.add_child(state_idle)
	main_state_machine.add_child(state_walk)
	main_state_machine.add_child(state_run)
	main_state_machine.add_child(state_jump)
	main_state_machine.add_child(state_dash)
	main_state_machine.add_child(state_attack)
	
	main_state_machine.initial_state = state_idle
	
	#ENTER IDLE STATE
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_idle, to_idle)
	
	#ENTER JUMP STATE
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_jump, to_jump)
	
	#ENTER DASH STATE
	main_state_machine.add_transition(state_idle, state_dash, to_dash)
	main_state_machine.add_transition(state_walk, state_dash, to_dash)
	main_state_machine.add_transition(state_run, state_dash, to_dash)
	
	#ENTER ATTACK STATE
	main_state_machine.add_transition(state_idle, state_attack, to_attack)	
	main_state_machine.add_transition(state_walk, state_attack, to_attack)	
	main_state_machine.add_transition(state_jump, state_attack, to_attack)	
	main_state_machine.add_transition(state_dash, state_attack, to_attack)	
	
	#ENTER WALK STATE
	main_state_machine.add_transition(state_idle, state_walk, to_walk)
	
	#ENTER RUN STATE
	main_state_machine.add_transition(state_idle, state_run, to_run)
	main_state_machine.add_transition(state_walk, state_run, to_run)
	
	main_state_machine.initialize(self)
	main_state_machine.set_active(true)
	
func _state_idle_enter():
	state_changed.emit("idle", velocity)
	
func _state_idle_update(_delta:float):
	state_changed.emit("idle", velocity)
	if int(velocity.x) != 0:
		main_state_machine.dispatch(to_walk)

func _state_walk_enter():
	current_speed = speed
	state_changed.emit("walk", velocity)
	
func _state_walk_update(_delta:float):
	if int(velocity.x) == 0:
		main_state_machine.dispatch(to_idle)
	else:
		state_changed.emit("walk", velocity)
		
func _state_run_enter():
	current_speed = speed * run_multiplier
	
func _state_run_update(_delta:float):
	if int(velocity.x) == 0:
		main_state_machine.dispatch(to_idle)
	else:
		state_changed.emit("run", velocity)
	
func _state_jump_enter():
	if is_on_floor():
		state_changed.emit("jump", velocity)
		var gravity = get_gravity().y
		jump_velocity = -sqrt(2 * gravity * jump_height)
		velocity.y = jump_velocity

func _state_jump_update(_delta:float):
	state_changed.emit("jump", velocity)
	if is_on_floor():
		main_state_machine.dispatch(to_idle)
	
func _state_attack_enter():
	if is_attacking:
		return

	attack_box.monitorable = true
	attack_box.monitoring = true
	is_attacking = true
	state_changed.emit("attack", velocity)
	
func _state_attack_update(_delta:float):
	pass

func _state_attack_exit():
	attack_box.monitorable = false
	attack_box.monitoring = false
	is_attacking = false

func _state_dash_enter():
	if is_dashing || current_dash_cooldown > 0:
		return
		
	is_dashing = true
	current_dash_duration = dash_duration
	current_speed = dash_speed
	
func _state_dash_update(delta:float):
	current_dash_duration -= delta
	
	current_time_duplication+= delta
	if current_time_duplication > duplication_time:
		current_time_duplication = 0
		_create_duplication()
	
	if current_dash_duration < 0:
		is_dashing = false
		main_state_machine.dispatch(to_idle)
		current_dash_cooldown = dash_cooldown
		current_speed = speed

func _can_move():
	return not is_attacking
	
func _handle_jump_buffer(delta):
	# Decrease the buffer timer 
	if current_jump_buffer_timer > 0: 
		current_jump_buffer_timer -= delta 
	else: 
		jump_buffer = false
		
	# Handle landing 
	if is_on_floor() and jump_buffer: 
		main_state_machine.dispatch(to_jump)
		jump_buffer = false
		current_jump_buffer_timer = 0

var current_time_duplication: float = 0
var duplication_time: float = .025
var duplcation_lifetime: float = .2

func _create_duplication():
	var duplicado = $Sprite2D.duplicate(true)
	duplicado.material = $Sprite2D.material.duplicate(true)
	duplicado.material.set_shader_parameter("opacity", 0.3)
	duplicado.material.set_shader_parameter("r", 0.0)
	duplicado.material.set_shader_parameter("g", 0.0)
	duplicado.material.set_shader_parameter("b", 0.8)
	duplicado.material.set_shader_parameter("mix_color", 0.7)
	duplicado.position.y += position.y

	if $Sprite2D.scale.x == -1:
		duplicado.position.x = position.x - duplicado.position.x
	else:
		duplicado.position.x += position.x
	duplicado.z_index -= 1
	get_parent().add_child(duplicado)
	await get_tree().create_timer(duplcation_lifetime).timeout
	duplicado. queue_free()
