class_name Player extends CharacterBody2D

const THROWABLE = preload("res://weapons/throwable.tscn")

signal state_changed(current_state: String, velocity: Vector2)

@onready var health: Health = $Health
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_box: AttackBox = $AttackBox
@onready var attack_collision_shape_2d: CollisionShape2D = $AttackBox/CollisionShape2D
@onready var parry_box: Area2D = $ParryBox

## The base speed
@export var speed: float = 64
## The max height that the player can jump
@export var jump_height: int = 64
## The jump buffer time in seconds, used to allow player to make mistakes when jumping
@export var jump_buffer_time: float = 0.1 # Buffer time in seconds
@export var max_jumps: int = 2

## The value that will multiply the speed when running
@export var run_multiplier: float = 2.5
@export var acceleration: int = 10 
@export var deceleration: int = 50

@export var dash_speed = 400.0
@export var dash_duration = 0.2
@export var dash_cooldown = 1.0

@export var strong_attack_threshold: float = 0.2

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

var current_speed: float = 0
var last_direction: String = "right"

var is_attacking: bool = false
var strong_attack_time: float = 0


var is_parrying: bool = false
var throw_speed: int = 100

# jump
var current_jumps: int = 0
var jump_velocity: float = 0
var jump_buffer: bool = false 
var current_jump_buffer_timer: float = 0.0
var jump_down_buffer = false

# dash duplication
var current_time_duplication: float = 0
var duplication_time: float = .020
var duplcation_lifetime: float = .2

# state machine
var main_state_machine: LimboHSM
var to_idle: StringName = &"state_ended"
var to_jump: StringName = &"to_jump"
var to_down: StringName = &"to_down"
var to_walk: StringName = &"to_walk"
var to_run: StringName = &"to_run"
var to_prepare_attack: StringName = &"to_prepare_attack"
var to_attack: StringName = &"to_attack"
var to_strong_attack: StringName = &"to_strong_attack"
var to_parry: StringName = &"to_parry"
var to_dash: StringName = &"to_dash"
var to_dash_attack: StringName = &"to_dash_attack"
var to_throw_attack: StringName = &"to_throw_attack"
var to_hold_throw_attack: StringName = &"to_hold_throw_attack"

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
	if Input.is_action_pressed("player_down") and Input.is_action_just_pressed("player_jump"):
		main_state_machine.dispatch(to_down)
		jump_down_buffer = true
	if event.is_action_pressed("player_jump"):
		if not jump_down_buffer:
			if is_on_floor():
				main_state_machine.dispatch(to_jump)
			else:
				if current_jumps < max_jumps:
					_perform_jump()
				else:
					jump_buffer = true 
					current_jump_buffer_timer = jump_buffer_time
		jump_down_buffer = false
			
	if event.is_action_pressed("player_dash") and !is_dashing and dash_cooldown_timer == 0: 
		main_state_machine.dispatch(to_dash)
	
	## ATTACK
	if event.is_action_pressed("player_attack") and is_dashing:
		main_state_machine.dispatch(to_dash_attack)
	if event.is_action_pressed("player_attack"):
		main_state_machine.dispatch(to_prepare_attack)
	if event.is_action_released("player_attack"):
		if strong_attack_time >= strong_attack_threshold:
			main_state_machine.dispatch(to_strong_attack)
		else:
			main_state_machine.dispatch(to_attack)
	## ATTACK
	if event.is_action_pressed("player_throw"):
		main_state_machine.dispatch(to_hold_throw_attack)
	if event.is_action_released("player_parry"):
		main_state_machine.dispatch(to_parry)

func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("player_run"):
		main_state_machine.dispatch(to_run)
		
	if DebugUI.ON:
		var debug_message_template:= "[color=green][b] %s [/b][/color]: %s \n"
		var debug_message:= ""

		debug_message +=debug_message_template %["Health:",health.current_health]
		debug_message +=debug_message_template %["Speed:",current_speed]
		debug_message +=debug_message_template %["Can Move:",_can_move()]
		debug_message +=debug_message_template %["Last Direction:",velocity.x]
		debug_message +=debug_message_template %["Velocity:",velocity]
		debug_message +=debug_message_template %["Current Jumps:", current_jumps]
		debug_message +=debug_message_template %["Jump Buffer Active:", jump_buffer]
		debug_message +=debug_message_template %["Jump Buffer Timer:", current_jump_buffer_timer]
		debug_message +=debug_message_template %["Dash Timer:", dash_timer]
		debug_message +=debug_message_template %["Dash Cooldown Timer:", dash_cooldown_timer]
		
		var current_state = ""
		if main_state_machine != null:
			current_state = main_state_machine.get_active_state().name
		debug_message +=debug_message_template %["Current State", current_state]
		debug_message +="_______________________________\n"

		DebugUI.show_message(debug_message)

func _physics_process(delta: float) -> void:
	
	if _can_move() == false and is_on_floor():
		velocity.x = 0
		
	dash_cooldown_timer -= delta
	if dash_cooldown_timer < 0:
		dash_cooldown_timer = 0
		
	_handle_jump_buffer(delta)
	
	if !is_dashing and !is_attacking:
		# Get the input direction and handle the movement/deceleration.
		var direction: float = Input.get_axis("player_left", "player_right")
		
		if direction > 0:
			last_direction = "right"
		elif direction < 0:
			last_direction = "left"
		
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
	
	# Apply gravity
	_apply_gravity(delta)
	# Move the character
	move_and_slide()

func _apply_gravity(delta):
	
	if not is_on_floor():
		if velocity.y < 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 1.2

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("parry"):
		main_state_machine.dispatch(to_idle)
		
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

func _create_duplication():
	var duplication: Sprite2D = sprite_2d.duplicate(true)
	duplication.material = sprite_2d.material.duplicate(true)
	duplication.material.set_shader_parameter("opacity", 0.3)
	duplication.material.set_shader_parameter("r", 0.0)
	duplication.material.set_shader_parameter("g", 0.0)
	duplication.material.set_shader_parameter("b", 0.8)
	duplication.material.set_shader_parameter("mix_color", 0.7)
	duplication.position.y += position.y

	if sprite_2d.scale.x == -1:
		duplication.position.x = position.x - duplication.position.x
	else:
		duplication.position.x += position.x
	duplication.z_index -= 1
	get_parent().add_child(duplication)
	await get_tree().create_timer(duplcation_lifetime).timeout
	duplication.queue_free()
		
func _initiate_state_machine():
	main_state_machine = LimboHSM.new()
	add_child(main_state_machine)
	
	var state_idle = LimboState.new().named("idle").call_on_enter(_state_idle_enter).call_on_update(_state_idle_update)
	var state_walk = LimboState.new().named("walk").call_on_enter(_state_walk_enter).call_on_update(_state_walk_update)
	var state_run = LimboState.new().named("run").call_on_enter(_state_run_enter).call_on_update(_state_run_update)
	var state_jump = LimboState.new().named("jump").call_on_enter(_state_jump_enter).call_on_update(_state_jump_update)
	var state_down = LimboState.new().named("down").call_on_enter(_state_down_enter).call_on_update(_state_down_update)
	var state_dash = LimboState.new().named("dash").call_on_enter(_state_dash_enter).call_on_update(_state_dash_update).call_on_exit(_state_dash_exit)
	var state_dash_attack = LimboState.new().named("dash_attack").call_on_enter(_state_dash_attack_enter).call_on_update(_state_dash_attack_update)
	var satate_prepare_attack = LimboState.new().named("prepare_attack").call_on_enter(_state_prepare_attack_enter).call_on_update(_state_prepare_attack_update)
	var state_attack = LimboState.new().named("attack").call_on_enter(_state_attack_enter).call_on_update(_state_attack_update).call_on_exit(_state_attack_exit)
	var state_strong_attack = LimboState.new().named("strong_attack").call_on_enter(_state_strong_attack_enter).call_on_update(_state_strong_attack_update).call_on_exit(_state_strong_attack_exit)
	var state_parry = LimboState.new().named("parry").call_on_enter(_state_parry_enter).call_on_update(_state_parry_update).call_on_exit(_state_parry_exit)
	var state_hold_throw_attack = LimboState.new().named(to_hold_throw_attack).call_on_enter(_state_hold_throw_attack_enter).call_on_update(_state_hold_throw_attack_update)
	var state_throw_attack = LimboState.new().named(to_throw_attack).call_on_enter(_state_throw_attack_enter).call_on_update(_state_throw_attack_update)
	
	main_state_machine.add_child(state_idle)
	main_state_machine.add_child(state_walk)
	main_state_machine.add_child(state_run)
	main_state_machine.add_child(state_jump)
	main_state_machine.add_child(state_down)
	main_state_machine.add_child(state_dash)
	main_state_machine.add_child(state_dash_attack)
	main_state_machine.add_child(satate_prepare_attack)
	main_state_machine.add_child(state_attack)
	main_state_machine.add_child(state_strong_attack)
	main_state_machine.add_child(state_parry)
	main_state_machine.add_child(state_hold_throw_attack)
	main_state_machine.add_child(state_throw_attack)
	
	main_state_machine.initial_state = state_idle
	
	#ENTER IDLE STATE
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_idle, to_idle)
	
	#ENTER JUMP STATE
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_jump, to_jump)
	
	#ENTER DOWN STATE
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_down, to_down)
	
	#ENTER DASH STATE
	main_state_machine.add_transition(state_idle, state_dash, to_dash)
	main_state_machine.add_transition(state_walk, state_dash, to_dash)
	main_state_machine.add_transition(state_run, state_dash, to_dash)
	
	#ENTER DASH ATTACK STATE
	main_state_machine.add_transition(state_dash, state_dash_attack, to_dash_attack)
	
	#ENTER PREPARE ATTACK STATE
	main_state_machine.add_transition(state_idle, satate_prepare_attack, to_prepare_attack)	
	main_state_machine.add_transition(state_walk, satate_prepare_attack, to_prepare_attack)	
	main_state_machine.add_transition(state_run, satate_prepare_attack, to_prepare_attack)	
	main_state_machine.add_transition(state_jump, satate_prepare_attack, to_prepare_attack)	
	main_state_machine.add_transition(state_dash, satate_prepare_attack, to_prepare_attack)	
	
	#ENTER ATTACK STATE
	main_state_machine.add_transition(satate_prepare_attack, state_attack, to_attack)	
	
	#ENTER STRONG ATTACK STATE
	main_state_machine.add_transition(satate_prepare_attack, state_strong_attack, to_strong_attack)	

	#ENTER PARRY STATE
	main_state_machine.add_transition(state_idle, state_parry, to_parry)
	main_state_machine.add_transition(state_walk, state_parry, to_parry)
	main_state_machine.add_transition(state_run, state_parry, to_parry)
	
	#ENTER HOLD THROW ATTACK STATE
	main_state_machine.add_transition(state_idle, state_hold_throw_attack, to_hold_throw_attack)
	main_state_machine.add_transition(state_walk, state_hold_throw_attack, to_hold_throw_attack)
	main_state_machine.add_transition(state_run, state_hold_throw_attack, to_hold_throw_attack)
	
	#ENTER THROW ATTACK STATE
	main_state_machine.add_transition(state_hold_throw_attack, state_throw_attack, to_throw_attack)	
	
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
		_perform_jump()

func _state_jump_update(_delta:float):
	state_changed.emit("jump", velocity)
	
	if is_on_floor():
		main_state_machine.dispatch(to_idle)
		current_jumps = 0

var collision_down_timeout = 0
var collision_down_duration = .1
func _state_down_enter():
	if is_on_floor():
		# Temporarily disable one-way collision to allow dropping through
		set_collision_mask_value(15, false)
		collision_down_timeout = collision_down_duration

func _state_down_update(delta:float):
	
	collision_down_timeout -= delta
	if collision_down_timeout <= 0:
		set_collision_mask_value(15, true)
		main_state_machine.dispatch(to_jump)
	
func _perform_jump():
	state_changed.emit("jump", velocity)
	var gravity = get_gravity().y
	jump_velocity = -sqrt(2 * gravity * jump_height)
	velocity.y = jump_velocity
	current_jumps += 1
	
func _state_prepare_attack_enter():
	strong_attack_time = 0
	
func _state_prepare_attack_update(delta: float):
	strong_attack_time += delta
	if strong_attack_time > strong_attack_threshold:
		state_changed.emit("holding_attack", velocity)
	
func _state_attack_enter():
	if is_attacking:
		return

	attack_box.monitorable = true
	attack_box.monitoring = true
	is_attacking = true
	state_changed.emit("attack", velocity)
	
func _state_attack_update(_delta:float):
	if animation_player.current_animation.begins_with("attack_") == false:
		if is_on_floor():
			main_state_machine.dispatch(to_idle)
		else:
			main_state_machine.dispatch(to_jump)

func _state_attack_exit():
	attack_box.monitorable = false
	attack_box.monitoring = false
	is_attacking = false
	
func _state_strong_attack_enter():
	if is_attacking:
		return

	attack_box.monitorable = true
	attack_box.monitoring = true
	is_attacking = true
	state_changed.emit("strong_attack", velocity)
	
func _state_strong_attack_update(_delta: float):
	if animation_player.current_animation != "strong_attack":
		if is_on_floor():
			main_state_machine.dispatch(to_idle)
		else:
			main_state_machine.dispatch(to_jump)
	
func _state_strong_attack_exit():
	attack_box.monitorable = false
	attack_box.monitoring = false
	is_attacking = false

func _state_parry_enter():
	
	is_parrying = true
	parry_box.monitoring = true
	parry_box.monitorable = true
	state_changed.emit("parry", velocity)
	
func _state_parry_update(_delta:float):
	pass

func _state_parry_exit():
	is_parrying = false
	parry_box.monitoring = false
	parry_box.monitorable = false

func _state_hold_throw_attack_enter():
	is_attacking = true
	state_changed.emit("hold_throw", velocity)

func _state_hold_throw_attack_update(_delta):
	throw_speed += 10
	if Input.is_action_just_released("player_throw"):
		main_state_machine.dispatch(to_throw_attack)

func _state_throw_attack_enter():
	
	var new_projectile: Throwable = THROWABLE.instantiate()
	new_projectile.global_position = Vector2(global_position.x, global_position.y - 32)
	new_projectile.explosion = load("res://weapons/acid.tscn")
	
	new_projectile.throw(last_direction, 45, throw_speed)

	var first_node = get_tree().current_scene.get_child(0)
	(first_node as Node2D).add_sibling(new_projectile)
	state_changed.emit("throw", velocity)

func _state_throw_attack_update(_delta):
	if animation_player.current_animation != "throw":
		is_attacking = false
		throw_speed = 100	
		main_state_machine.dispatch(to_idle)

func _state_dash_enter():
	is_dashing = true
	state_changed.emit("dash", velocity)
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	if Input.is_action_pressed("player_left"):
		velocity.x = -dash_speed
		last_direction = "left"
	elif Input.is_action_pressed("player_right"):
		velocity.x = dash_speed
		last_direction = "right"
	
func _state_dash_update(delta:float):
	state_changed.emit("dash", velocity)
	if is_dashing:
		dash_timer -= delta
	if dash_timer <= 0:
		main_state_machine.dispatch(to_idle)
		
	current_time_duplication+= delta
	if current_time_duplication > duplication_time:
		current_time_duplication = 0
		_create_duplication()

func _state_dash_exit():
	is_dashing = false
	velocity.x = 0 # Stop the dash movement
	
func _state_dash_attack_enter():
	is_dashing = true
	state_changed.emit("dash_attack", velocity)
	
func _state_dash_attack_update(_delta:float):
	if animation_player.current_animation != "dash_attack":
		is_dashing = false
		main_state_machine.dispatch(to_idle)
