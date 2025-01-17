class_name Player extends CharacterBody2D

const THROWABLE = preload("res://weapons/throwable.tscn")
const MIN_THROW_SPEED: int = 200

signal state_changed(current_state: String, velocity: Vector2)

@onready var health: Health = $Health
@onready var hurt_box: HurtBox = $HurtBox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_being_hit: AnimationPlayer = $AnimationPlayerBeingHit
@onready var attack_collision_shape_2d: CollisionShape2D = $AttackBox/CollisionShape2D
@onready var shape_cast_2d_left: ShapeCast2D = $ShapeCast2DLeft
@onready var shape_cast_2d_right: ShapeCast2D = $ShapeCast2DRight
@onready var ray_cast_2d_foot_left: RayCast2D = $RayCast2DFootLeft
@onready var ray_cast_2d_foot_right: RayCast2D = $RayCast2DFootRight
@onready var throw_hand: Node2D = $ThrowHand
@onready var inventory: Inventory = $Inventory
@onready var follow_camera: FollowCamera = $FollowCamera

@export_group("Attack")
@export var strong_attack_threshold: float = 0.2
@export var max_throw_ammunition: int = 3

@export_group("Jump")
## The max height that the player can jump
@export var jump_height: int = 128
## The jump buffer time in seconds, used to allow player to make mistakes when jumping
@export var jump_buffer_time: float = 0.1 # Buffer time in seconds
@export var max_jumps: int = 2
@export var wall_walk_multiplier: float = 3.0

@export_group("Walk-Run")
@export var speed: float = 64
## The value that will multiply the speed when running
@export var run_multiplier: float = 2.5
@export var acceleration: int = 10 
@export var deceleration: int = 50

@export_group("Dash")
@export var dash_speed = 400.0
@export var dash_duration = 0.3
@export var dash_cooldown = 1.0

enum WALL_WALK_DIRECTION {NONE, LEFT, RIGHT}
var wall_walking_direction = WALL_WALK_DIRECTION.NONE
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

var current_speed: float = 0
var last_direction: String = "right"

var is_attacking: bool = false
var is_dead: bool = false
var strong_attack_time: float = 0

var is_parrying: bool = false
var throw_speed: int = MIN_THROW_SPEED
var throw_ammunition: float = max_throw_ammunition * 10

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

var collision_down_timeout = 0
var collision_down_duration = .1

# state machine
var main_state_machine: LimboHSM
var to_idle: StringName = &"state_ended"
var to_jump: StringName = &"to_jump"
var to_down: StringName = &"to_down"
var to_walk: StringName = &"to_walk"
var to_run: StringName = &"to_run"
var to_prepare_attack: StringName = &"to_prepare_attack"
var to_attack: StringName = &"to_attack"
var to_jump_attack: StringName = &"to_jump_attack"
var to_strong_attack: StringName = &"to_strong_attack"
var to_parry: StringName = &"to_parry"
var to_dash: StringName = &"to_dash"
var to_dash_attack: StringName = &"to_dash_attack"
var to_throw_attack: StringName = &"to_throw_attack"
var to_hold_throw_attack: StringName = &"to_hold_throw_attack"
var to_wall_idle: StringName = &"to_wall_idle"
var to_walk_wall_left: StringName = &"to_walk_wall_left"
var to_walk_wall_right: StringName = &"to_walk_wall_right"
var to_wall_jump: StringName = &"to_wall_jump"
var to_shade: StringName = &"to_shade"
var to_dead: StringName = &"to_dead"

func  _ready() -> void:
	current_speed = speed
	
	animation_player.animation_finished.connect(_on_animation_finished)
	hurt_box.damaged.connect(_on_hurt_box_damaged)
	health.health_empty.connect(_on_health_empty)
	
	_initiate_state_machine()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			DebugUI.ON = not DebugUI.ON
	if event.is_action_pressed("player_run"):
		main_state_machine.dispatch(to_run)
	if event.is_action_released("player_run") and is_on_floor():
		main_state_machine.dispatch(to_idle)
	if Input.is_action_pressed("player_down") and Input.is_action_just_pressed("player_jump"):
		main_state_machine.dispatch(to_down)
		jump_down_buffer = true
	if event.is_action_pressed("player_jump"):
		if wall_walking_direction != WALL_WALK_DIRECTION.NONE:
			main_state_machine.dispatch(to_wall_jump)
		elif not jump_down_buffer:
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
	elif event.is_action_pressed("player_attack") and velocity.y != 0:
		main_state_machine.dispatch(to_jump_attack)
	elif event.is_action_pressed("player_attack"):
		main_state_machine.dispatch(to_prepare_attack)
	if event.is_action_released("player_attack"):
		if strong_attack_time >= strong_attack_threshold:
			main_state_machine.dispatch(to_strong_attack)
		else:
			main_state_machine.dispatch(to_attack)
	
	if event.is_action_pressed("player_throw"):
		main_state_machine.dispatch(to_hold_throw_attack)
	if event.is_action_released("player_parry"):
		main_state_machine.dispatch(to_parry)
	if event.is_action_released("player_shade"):
		main_state_machine.dispatch(to_shade)

func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("player_run"):
		main_state_machine.dispatch(to_run)
		
	if Input.is_action_pressed("player_left") or Input.is_action_pressed("player_right"):
		main_state_machine.dispatch(to_walk)
		
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
		debug_message +=debug_message_template %["Money:", inventory.has_item("money").size()]
		debug_message +=debug_message_template %["Ammo:", throw_ammunition]
		
		var current_state = ""
		if main_state_machine != null:
			current_state = main_state_machine.get_active_state().name
		debug_message +=debug_message_template %["Current State", current_state]
		debug_message +="_______________________________\n"

		DebugUI.show_message(debug_message)
	else:
		DebugUI.clear()

func _physics_process(delta: float) -> void:
	
	if shape_cast_2d_left.is_colliding() and wall_walking_direction == WALL_WALK_DIRECTION.NONE:
		main_state_machine.dispatch(to_walk_wall_left)
	elif shape_cast_2d_right.is_colliding() and wall_walking_direction == WALL_WALK_DIRECTION.NONE:
		main_state_machine.dispatch(to_walk_wall_right)
		
	if _can_move() == false and is_on_floor():
		velocity.x = 0
		
	dash_cooldown_timer -= delta
	if dash_cooldown_timer < 0:
		dash_cooldown_timer = 0
		
	if throw_ammunition < max_throw_ammunition * 10:
		throw_ammunition += delta
		
	_handle_jump_buffer(delta)
	
	# Apply gravity
	_apply_gravity(delta)
	
	# Move the character
	move_and_slide()

func _apply_gravity(delta):
	
	var current_state = main_state_machine.get_active_state().name
	if not is_on_floor() and current_state != "walk_wall_left":
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
	
func _perform_jump():
	state_changed.emit("jump", velocity)
	var gravity = get_gravity().y
	jump_velocity = -sqrt(2 * gravity * jump_height)
	velocity.y = jump_velocity
	current_jumps += 1
	
func _perform_wall_jump(direction: WALL_WALK_DIRECTION):
	state_changed.emit("jump", velocity)
	var gravity = get_gravity().y
	jump_velocity = -sqrt(2 * gravity * jump_height)
	
	if direction == WALL_WALK_DIRECTION.LEFT:
		velocity = Vector2(-jump_velocity/2, jump_velocity)
	elif  direction == WALL_WALK_DIRECTION.RIGHT:
		velocity = Vector2(jump_velocity/2, jump_velocity)
	current_jumps = 1
	
func _perform_move_on_floor(delta: float):
	var direction: float = Input.get_axis("player_left", "player_right")
	
	if direction > 0:
		last_direction = "right"
	elif direction < 0:
		last_direction = "left"
	
	if direction:
		velocity = velocity.lerp(Vector2(direction, 0) * current_speed, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2(direction, 0) * current_speed, deceleration * delta)	

func _perform_move_on_wall_right(delta: float):
	
	var direction: float = Input.get_axis("player_up", "player_down")
	
	if direction > 0:
		last_direction = "left"
	elif direction < 0:
		last_direction = "right"
	
	if direction > 0 and ray_cast_2d_foot_left.is_colliding():
		velocity = velocity.lerp(Vector2(0, direction) * current_speed, acceleration * delta)
	elif direction < 0 and ray_cast_2d_foot_right.is_colliding():
		velocity = velocity.lerp(Vector2(0, direction) * current_speed, deceleration * delta)	
	else:
		velocity.y = 0
		
func _perform_move_on_wall_left(delta: float):
	
	var direction: float = Input.get_axis("player_up", "player_down")
	
	if direction > 0:
		last_direction = "left"
	elif direction < 0:
		last_direction = "right"
	
	if direction > 0 and ray_cast_2d_foot_right.is_colliding():
		velocity = velocity.lerp(Vector2(0, direction) * current_speed, acceleration * delta)
	elif direction < 0 and ray_cast_2d_foot_left.is_colliding():
		velocity = velocity.lerp(Vector2(0, direction) * current_speed, deceleration * delta)	
	else:
		velocity.y = 0
	
func _perform_move_on_jump(_delta: float):
	var direction: float = Input.get_axis("player_left", "player_right")
	
	if direction > 0:
		last_direction = "right"
	elif direction < 0:
		last_direction = "left"
	
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

func _on_hurt_box_damaged(damage: int, area: AttackBox):
	
	if is_dead:
		return
		
	if is_parrying:
		area.parry(self)
		return
	
	#var damager_position = area.global_position
	#var move_direction = (damager_position - global_position).normalized()
	
	health.decrease_health(damage)
	
	#push back
	if last_direction == "right":
		velocity = Vector2(1, 0)
		global_position.x -= 10
	else:
		global_position.x += 10
		velocity = Vector2(-1, 0)
	
	#play hit animation if is not being played
	if !animation_player_being_hit.is_playing():
		animation_player_being_hit.play("hit")
		
func _on_health_empty():
	main_state_machine.dispatch(to_dead)

func move_forward(distance: int = 5):
	
	if last_direction == "right":
		velocity = Vector2(1, 0)
		global_position.x += distance
	else:
		global_position.x -= distance
		velocity = Vector2(-1, 0)

#region STATE MACHINE

func _initiate_state_machine():
	main_state_machine = LimboHSM.new()
	add_child(main_state_machine)
	
	var state_idle: LimboState = LimboState.new().named("idle").call_on_enter(_state_idle_enter).call_on_update(_state_idle_update)
	var state_walk: LimboState = LimboState.new().named("walk").call_on_enter(_state_walk_enter).call_on_update(_state_walk_update)
	var state_wall_idle: LimboState = LimboState.new().named("wall_idle").call_on_enter(_state_wall_idle_enter).call_on_update(_state_wall_idle_update)
	var state_walk_wall_left: LimboState = LimboState.new().named("walk_wall_left").call_on_enter(_state_walk_wall_left_enter).call_on_update(_state_walk_wall_left_update)
	var state_walk_wall_right: LimboState = LimboState.new().named("walk_wall_right").call_on_enter(_state_walk_wall_right_enter).call_on_update(_state_walk_wall_right_update)
	var state_wall_jump: LimboState = LimboState.new().named("wall_jump").call_on_enter(_state_wall_jump_enter).call_on_update(_state_wall_jump_update)
	var state_run: LimboState = LimboState.new().named("run").call_on_enter(_state_run_enter).call_on_update(_state_run_update)
	var state_jump: LimboState = LimboState.new().named("jump").call_on_enter(_state_jump_enter).call_on_update(_state_jump_update)
	var state_down: LimboState = LimboState.new().named("down").call_on_enter(_state_down_enter).call_on_update(_state_down_update)
	var state_dash: LimboState = LimboState.new().named("dash").call_on_enter(_state_dash_enter).call_on_update(_state_dash_update).call_on_exit(_state_dash_exit)
	var state_dash_attack: LimboState = LimboState.new().named("dash_attack").call_on_enter(_state_dash_attack_enter).call_on_update(_state_dash_attack_update)
	var state_attack: LimboState = LimboState.new().named("attack").call_on_enter(_state_attack_enter).call_on_update(_state_attack_update).call_on_exit(_state_attack_exit)
	var state_jump_attack: LimboState = LimboState.new().named("jump_attack").call_on_enter(_state_jump_attack_enter).call_on_update(_state_jump_attack_update).call_on_exit(_state_jump_attack_exit)
	var state_prepare_attack: LimboState = LimboState.new().named("prepare_attack").call_on_enter(_state_prepare_attack_enter).call_on_update(_state_prepare_attack_update)
	var state_strong_attack: LimboState = LimboState.new().named("strong_attack").call_on_enter(_state_strong_attack_enter).call_on_update(_state_strong_attack_update).call_on_exit(_state_strong_attack_exit)
	var state_parry: LimboState = LimboState.new().named("parry").call_on_enter(_state_parry_enter).call_on_update(_state_parry_update).call_on_exit(_state_parry_exit)
	var state_hold_throw_attack: LimboState = LimboState.new().named("hold_throw_attack").call_on_enter(_state_hold_throw_attack_enter).call_on_update(_state_hold_throw_attack_update)
	var state_throw_attack: LimboState = LimboState.new().named("throw_attack").call_on_enter(_state_throw_attack_enter).call_on_update(_state_throw_attack_update)
	var state_shade: LimboState = LimboState.new().named("shade").call_on_enter(_state_shade_enter).call_on_update(_state_shade_update)
	var state_dead: LimboState = LimboState.new().named("dead").call_on_enter(_state_dead_enter).call_on_update(_state_dead_update)
	
	main_state_machine.add_child(state_idle)
	main_state_machine.add_child(state_walk)
	main_state_machine.add_child(state_wall_idle)
	main_state_machine.add_child(state_walk_wall_left)
	main_state_machine.add_child(state_walk_wall_right)
	main_state_machine.add_child(state_wall_jump)
	main_state_machine.add_child(state_run)
	main_state_machine.add_child(state_jump)
	main_state_machine.add_child(state_down)
	main_state_machine.add_child(state_dash)
	main_state_machine.add_child(state_dash_attack)
	main_state_machine.add_child(state_prepare_attack)
	main_state_machine.add_child(state_attack)
	main_state_machine.add_child(state_jump_attack)
	main_state_machine.add_child(state_strong_attack)
	main_state_machine.add_child(state_parry)
	main_state_machine.add_child(state_hold_throw_attack)
	main_state_machine.add_child(state_throw_attack)
	main_state_machine.add_child(state_shade)
	main_state_machine.add_child(state_dead)
	
	main_state_machine.initial_state = state_idle
	
	#ENTER DEAD STATE
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_dead, to_dead)
	
	#ENTER IDLE STATE
	main_state_machine.add_transition(state_walk, state_idle, to_idle)
	main_state_machine.add_transition(state_run, state_idle, to_idle)
	main_state_machine.add_transition(state_jump, state_idle, to_idle)
	main_state_machine.add_transition(state_down, state_idle, to_idle)
	main_state_machine.add_transition(state_dash, state_idle, to_idle)
	main_state_machine.add_transition(state_dash_attack, state_idle, to_idle)
	main_state_machine.add_transition(state_prepare_attack, state_idle, to_idle)
	main_state_machine.add_transition(state_attack, state_idle, to_idle)
	main_state_machine.add_transition(state_strong_attack, state_idle, to_idle)
	main_state_machine.add_transition(state_parry, state_idle, to_idle)
	main_state_machine.add_transition(state_hold_throw_attack, state_idle, to_idle)
	main_state_machine.add_transition(state_throw_attack, state_idle, to_idle)
	main_state_machine.add_transition(state_shade, state_idle, to_idle)
	
	#ENTER JUMP STATE
	main_state_machine.add_transition(state_idle, state_jump, to_jump)
	main_state_machine.add_transition(state_walk, state_jump, to_jump)
	main_state_machine.add_transition(state_run, state_jump, to_jump)
	main_state_machine.add_transition(state_jump, state_jump, to_jump)
	main_state_machine.add_transition(state_down, state_jump, to_jump)
	main_state_machine.add_transition(state_dash, state_jump, to_jump)
	main_state_machine.add_transition(state_dash_attack, state_jump, to_jump)
	main_state_machine.add_transition(state_attack, state_jump, to_jump)
	main_state_machine.add_transition(state_jump_attack, state_jump, to_jump)
	main_state_machine.add_transition(state_walk_wall_left, state_jump, to_jump)
	main_state_machine.add_transition(state_walk_wall_right, state_jump, to_jump)
	main_state_machine.add_transition(state_wall_jump, state_jump, to_jump)
	
	#ENTER DOWN STATE
	main_state_machine.add_transition(state_idle, state_down, to_down)
	main_state_machine.add_transition(state_walk, state_down, to_down)
	main_state_machine.add_transition(state_run, state_down, to_down)
	
	#ENTER DASH STATE
	main_state_machine.add_transition(state_idle, state_dash, to_dash)
	main_state_machine.add_transition(state_walk, state_dash, to_dash)
	main_state_machine.add_transition(state_run, state_dash, to_dash)
	
	#ENTER DASH ATTACK STATE
	main_state_machine.add_transition(state_dash, state_dash_attack, to_dash_attack)
	
	#ENTER PREPARE ATTACK STATE
	main_state_machine.add_transition(state_idle, state_prepare_attack, to_prepare_attack)	
	main_state_machine.add_transition(state_walk, state_prepare_attack, to_prepare_attack)	
	main_state_machine.add_transition(state_run, state_prepare_attack, to_prepare_attack)	
	main_state_machine.add_transition(state_dash, state_prepare_attack, to_prepare_attack)	
	
	#ENTER ATTACK STATE
	main_state_machine.add_transition(state_prepare_attack, state_attack, to_attack)	
	
	#ENTER JUMP ATTACK STATE
	main_state_machine.add_transition(state_jump, state_jump_attack, to_jump_attack)	
	
	#ENTER STRONG ATTACK STATE
	main_state_machine.add_transition(state_prepare_attack, state_strong_attack, to_strong_attack)	

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
	
	#ENTER WALL IDLE STATE
	main_state_machine.add_transition(state_walk_wall_left, state_wall_idle, to_wall_idle)
	main_state_machine.add_transition(state_walk_wall_right, state_wall_idle, to_wall_idle)
	main_state_machine.add_transition(state_wall_jump, state_wall_idle, to_wall_idle)
	
	#ENTER WALK WALL STATE
	main_state_machine.add_transition(state_wall_idle, state_walk_wall_left, to_walk_wall_left)
	main_state_machine.add_transition(state_jump, state_walk_wall_left, to_walk_wall_left)
	main_state_machine.add_transition(state_walk_wall_right, state_walk_wall_left, to_walk_wall_left)
	
	main_state_machine.add_transition(state_wall_idle, state_walk_wall_right, to_walk_wall_right)
	main_state_machine.add_transition(state_jump, state_walk_wall_right, to_walk_wall_right)
	main_state_machine.add_transition(state_walk_wall_left, state_walk_wall_right, to_walk_wall_right)
	
	#ENTER WALL JUMP STATE
	main_state_machine.add_transition(state_wall_idle, state_wall_jump, to_wall_jump)
	main_state_machine.add_transition(state_walk_wall_left, state_wall_jump, to_wall_jump)
	main_state_machine.add_transition(state_walk_wall_right, state_wall_jump, to_wall_jump)
	
	#ENTER RUN STATE
	main_state_machine.add_transition(state_idle, state_run, to_run)
	main_state_machine.add_transition(state_walk, state_run, to_run)
	
	#ENTER SHADE STATE
	main_state_machine.add_transition(state_idle, state_shade, to_shade)
	
	main_state_machine.initialize(self)
	main_state_machine.set_active(true)
	
func _state_idle_enter():
	state_changed.emit("idle", velocity)
	
func _state_idle_update(_delta:float):
	state_changed.emit("idle", velocity)
	if velocity.x != 0:
		main_state_machine.dispatch(to_walk)

func _state_walk_enter():
	current_speed = speed
	
func _state_walk_update(delta:float):
	
	_perform_move_on_floor(delta)
	
	if int(velocity.x) == 0:
		main_state_machine.dispatch(to_idle)
		velocity.x = 0
	elif velocity.y != 0:
		main_state_machine.dispatch(to_jump)
	else:
		state_changed.emit("walk", velocity)

func _state_wall_idle_enter():
	pass

func _state_wall_idle_update(_delta: float):
	if int(velocity.y) != 0:
		if up_direction == Vector2.LEFT:
			state_changed.emit("walk_wall_right", velocity)
		else:
			state_changed.emit("walk_wall_left", velocity)

func _state_walk_wall_left_enter():
	rotate(PI/2)
	current_speed = speed * wall_walk_multiplier
	wall_walking_direction = WALL_WALK_DIRECTION.LEFT
	up_direction = Vector2.RIGHT

func _state_walk_wall_left_update(delta:float):
	
	if not is_on_floor():
		velocity += Vector2(-get_gravity().y,0) * delta * 5
	
	_perform_move_on_wall_left(delta)
	
	if int(velocity.y) == 0:
		state_changed.emit("wall_idle", velocity)
	else:
		state_changed.emit("walk_wall_left", velocity)
		
func _state_walk_wall_right_enter():
	rotate(-PI/2)
	current_speed = speed * wall_walk_multiplier
	wall_walking_direction = WALL_WALK_DIRECTION.RIGHT
	up_direction = Vector2.LEFT

func _state_walk_wall_right_update(delta:float):
	
	if not is_on_floor():
		velocity += Vector2(get_gravity().y,0) * delta * 5
	
	_perform_move_on_wall_right(delta)
	
	if int(velocity.y) == 0:
		state_changed.emit("wall_idle", velocity)
	else:
		state_changed.emit("walk_wall_right", velocity)
		
func _state_wall_jump_enter():
	if up_direction == Vector2.LEFT:
		rotate(PI/2)
	elif up_direction == Vector2.RIGHT:
		rotate(-PI/2)
		
	up_direction = Vector2.UP
	
func _state_wall_jump_update(_delta):
	if wall_walking_direction != WALL_WALK_DIRECTION.NONE:
		_perform_wall_jump(wall_walking_direction)
	
	if wall_walking_direction == WALL_WALK_DIRECTION.LEFT and shape_cast_2d_left.is_colliding() == false:
		main_state_machine.dispatch(to_jump)
		wall_walking_direction = WALL_WALK_DIRECTION.NONE
	if wall_walking_direction == WALL_WALK_DIRECTION.RIGHT and shape_cast_2d_right.is_colliding() == false:
		main_state_machine.dispatch(to_jump)
		wall_walking_direction = WALL_WALK_DIRECTION.NONE
	
func _state_run_enter():
	current_speed = speed * run_multiplier

func _state_run_update(delta:float):
	
	_perform_move_on_floor(delta)
	
	if int(velocity.x) == 0:
		main_state_machine.dispatch(to_idle)
	elif velocity.y != 0:
		main_state_machine.dispatch(to_jump)
	else:
		state_changed.emit("run", velocity)

func _state_jump_enter():
	if is_on_floor():
		_perform_jump()

func _state_jump_update(delta:float):
	state_changed.emit("jump", velocity)
	
	if is_on_floor():
		main_state_machine.dispatch(to_idle)
		current_jumps = 0
	else:
		_perform_move_on_jump(delta)

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
	
func _state_prepare_attack_enter():
	strong_attack_time = 0
	
func _state_prepare_attack_update(delta: float):
	strong_attack_time += delta
	if strong_attack_time > strong_attack_threshold:
		state_changed.emit("holding_attack", velocity)
	
func _state_attack_enter():
	if is_attacking:
		return
	is_attacking = true
	state_changed.emit("attack", velocity)
	
func _state_attack_update(_delta:float):
	if animation_player.current_animation.begins_with("attack_") == false:
		if is_on_floor():
			main_state_machine.dispatch(to_idle)
		else:
			main_state_machine.dispatch(to_jump)

func _state_attack_exit():
	is_attacking = false
	
func _state_jump_attack_enter():
	if is_attacking:
		return
	is_attacking = true
	state_changed.emit("jump_attack", velocity)
	
func _state_jump_attack_update(_delta:float):
	if animation_player.current_animation.begins_with("jump_attack_") == false:
		if is_on_floor():
			main_state_machine.dispatch(to_idle)
		else:
			main_state_machine.dispatch(to_jump)

func _state_jump_attack_exit():
	is_attacking = false
	
func _state_strong_attack_enter():
	if is_attacking:
		return

	is_attacking = true
	state_changed.emit("strong_attack", velocity)
	
func _state_strong_attack_update(_delta: float):
	if animation_player.current_animation != "strong_attack":
		if is_on_floor():
			main_state_machine.dispatch(to_idle)
		else:
			main_state_machine.dispatch(to_jump)
	
func _state_strong_attack_exit():
	is_attacking = false

func _state_parry_enter():
	
	is_parrying = true
	state_changed.emit("parry", velocity)
	
func _state_parry_update(_delta:float):
	if animation_player.current_animation.begins_with("parry_") == false:
		main_state_machine.dispatch(to_idle)
	
func _state_parry_exit():
	is_parrying = false

func _state_hold_throw_attack_enter():
	
	if throw_ammunition < 10:
		state_changed.emit("no_ammo")
		main_state_machine.dispatch(to_idle)
		return
	
	is_attacking = true
	state_changed.emit("hold_throw", velocity)

func _state_hold_throw_attack_update(_delta):
	throw_speed += 10
	if Input.is_action_just_released("player_throw"):
		main_state_machine.dispatch(to_throw_attack)

func _state_throw_attack_enter():
	
	var new_projectile: Throwable = THROWABLE.instantiate()
	new_projectile.global_position = throw_hand.global_position
	new_projectile.explosion = load("res://weapons/ball_explosion.tscn")
	
	new_projectile.throw(last_direction, throw_speed)

	var first_node = get_tree().current_scene.get_child(0)
	(first_node as Node2D).add_sibling(new_projectile)
	state_changed.emit("throw", velocity)

func _state_throw_attack_update(_delta):
	if animation_player.current_animation.begins_with("throw_") == false :
		is_attacking = false
		throw_speed = MIN_THROW_SPEED	
		main_state_machine.dispatch(to_idle)
		throw_ammunition -= 10

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
		
func _state_shade_enter():
	state_changed.emit("shade", velocity)

func _state_shade_update(_delta:float):
	if animation_player.current_animation.begins_with("shade") == false:
		main_state_machine.dispatch(to_idle)

func _state_dead_enter():
	is_dead = true

func _state_dead_update(_delta):
	if is_on_floor():
		state_changed.emit("dead", velocity)

#endregion
