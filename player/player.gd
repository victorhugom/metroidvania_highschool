class_name Player extends CharacterBody2D

# Constants
const MIN_THROW_SPEED: int = 200
const WALL_ROTATION_ANGLE = PI / 2
const COLLISION_LAYER_ONE_WAY = 15
const DASH_DUPLICATION_INTERVAL = 0.020

# Wall walking direction enum
enum WALL_WALK_DIRECTION { NONE, LEFT, RIGHT }
var wall_walking_direction = WALL_WALK_DIRECTION.NONE

# Signals
signal state_changed(current_state: String, velocity: Vector2)

# Nodes
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

# Exported variables
@export_group("Attack")
@export var strong_attack_threshold: float = 0.2
@export var max_throw_ammunition: int = 3

@export_group("Jump")
@export var jump_height: int = 128
@export var jump_buffer_time: float = 0.1
@export var max_jumps: int = 2
@export var wall_walk_multiplier: float = 3.0

@export_group("Walk-Run")
@export var speed: float = 64
@export var run_multiplier: float = 2.5
@export var acceleration: int = 10
@export var deceleration: int = 50

@export_group("Dash")
@export var dash_speed = 400.0
@export var dash_duration = 0.3
@export var dash_cooldown = 1.0

# State machine
var main_state_machine: LimboHSM

# Import states
const IdleState = preload("res://player/states/IdleState.gd")
const WalkState = preload("res://player/states/WalkState.gd")
const JumpState = preload("res://player/states/JumpState.gd")
const DashState = preload("res://player/states/DashState.gd")
const AttackState = preload("res://player/states/AttackState.gd")
const StrongAttackState = preload("res://player/states/StrongAttackState.gd")
const ParryState = preload("res://player/states/ParryState.gd")
const ThrowAttackState = preload("res://player/states/ThrowAttackState.gd")
const DeadState = preload("res://player/states/DeadState.gd")
const BusyState = preload("res://player/states/BusyState.gd")
const WallIdleState = preload("res://player/states/WallIdleState.gd")
const WalkWallLeftState = preload("res://player/states/WalkWallLeftState.gd")
const WalkWallRightState = preload("res://player/states/WalkWallRightState.gd")
const WallJumpState = preload("res://player/states/WallJumpState.gd")
const RunState = preload("res://player/states/RunState.gd")
const DownState = preload("res://player/states/DownState.gd")
const DashAttackState = preload("res://player/states/DashAttackState.gd")
const JumpAttackState = preload("res://player/states/JumpAttackState.gd")
const PrepareAttackState = preload("res://player/states/PrepareAttackState.gd")
const HoldThrowAttackState = preload("res://player/states/HoldThrowAttackState.gd")
const ShadeState = preload("res://player/states/ShadeState.gd")

# Movement variables
var current_speed: float = 0
var last_direction: String = "right"

# Attack variables
var is_attacking: bool = false
var strong_attack_time: float = 0

# State variables
var is_dead: bool = false
var is_busy: bool:
	set(value):
		is_busy = value
		if is_busy:
			velocity = Vector2.ZERO
			main_state_machine.dispatch(to_busy)
var is_parrying: bool = false

# Throw variables
var throw_speed: int = MIN_THROW_SPEED
var throw_ammunition: float = max_throw_ammunition * 10
var throwable_type: Throwable.TrowableType = Throwable.TrowableType.DEFAULT

# Jump variables
var current_jumps: int = 0
var jump_velocity: float = 0
var jump_buffer: bool = false
var current_jump_buffer_timer: float = 0.0
var jump_down_buffer = false

# Duplication variables
var current_time_duplication: float = 0
var duplication_time: float = DASH_DUPLICATION_INTERVAL
var duplcation_lifetime: float = .2

# Collision variables
var collision_down_timeout = 0
var collision_down_duration = .1

# Dash variables
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

# State transition signals
var to_idle: StringName = &"to_idle"
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
var to_busy: StringName = &"to_busy"
var to_dead: StringName = &"to_dead"

func  _ready() -> void:
	current_speed = speed
	
	animation_player.animation_finished.connect(_on_animation_finished)
	hurt_box.damaged.connect(_on_hurt_box_damaged)
	health.health_empty.connect(_on_health_empty)
	health.health_changed.connect(_on_health_change)
	
	Hud.health = health.current_health
	Hud.energy = throw_ammunition
	
	_initiate_state_machine()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		DebugUI.ON = not DebugUI.ON

	if event.is_action_pressed("player_run"):
		main_state_machine.dispatch(to_run)
	elif event.is_action_released("player_run") and is_on_floor():
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
			elif current_jumps < max_jumps:
				_perform_jump()
			else:
				jump_buffer = true 
				current_jump_buffer_timer = jump_buffer_time
		jump_down_buffer = false

	if event.is_action_pressed("player_dash") and not is_dashing and dash_cooldown_timer == 0: 
		main_state_machine.dispatch(to_dash)
	
	# Handle attack actions
	if event.is_action_pressed("player_attack"):
		if is_dashing:
			main_state_machine.dispatch(to_dash_attack)
		elif velocity.y != 0:
			main_state_machine.dispatch(to_jump_attack)
		else:
			main_state_machine.dispatch(to_prepare_attack)
	elif event.is_action_released("player_attack"):
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
		var debug_message_template := "[color=green][b] %s [/b][/color]: %s \n"
		var debug_message := ""

		debug_message += debug_message_template % ["Health:", health.current_health]
		debug_message += debug_message_template % ["Speed:", current_speed]
		debug_message += debug_message_template % ["Can Move:", _can_move()]
		debug_message += debug_message_template % ["Last Direction:", velocity.x]
		debug_message += debug_message_template % ["Velocity:", velocity]
		debug_message += debug_message_template % ["Current Jumps:", current_jumps]
		debug_message += debug_message_template % ["Jump Buffer Active:", jump_buffer]
		debug_message += debug_message_template % ["Jump Buffer Timer:", current_jump_buffer_timer]
		debug_message += debug_message_template % ["Dash Timer:", dash_timer]
		debug_message += debug_message_template % ["Dash Cooldown Timer:", dash_cooldown_timer]
		debug_message += debug_message_template % ["Ammo:", throw_ammunition]
		
		var current_state = main_state_machine.get_active_state().name
		debug_message += debug_message_template % ["Current State", current_state]
		debug_message += "_______________________________\n"
		
		debug_message += debug_message_template % ["Inventory:", ""]
		var items_grouped = inventory.get_items_grouped()
		for key in items_grouped.keys():
			debug_message += debug_message_template % [key, items_grouped[key]]

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
	Hud.energy = throw_ammunition
		
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
	
func _on_health_change(value: int):
	Hud.health = value

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
	
	# Load states
	var state_idle: LimboState = IdleState.new().named("idle")
	var state_walk: LimboState = WalkState.new().named("walk")
	var state_jump: LimboState = JumpState.new().named("jump")
	var state_dash: LimboState = DashState.new().named("dash")
	var state_attack: LimboState = AttackState.new().named("attack")
	var state_strong_attack: LimboState = StrongAttackState.new().named("strong_attack")
	var state_parry: LimboState = ParryState.new().named("parry")
	var state_throw_attack: LimboState = ThrowAttackState.new().named("throw_attack")
	var state_dead: LimboState = DeadState.new().named("dead")
	var state_busy: LimboState = BusyState.new().named("busy")
	var state_wall_idle: LimboState = WallIdleState.new().named("wall_idle")
	var state_walk_wall_left: LimboState = WalkWallLeftState.new().named("walk_wall_left")
	var state_walk_wall_right: LimboState = WalkWallRightState.new().named("walk_wall_right")
	var state_wall_jump: LimboState = WallJumpState.new().named("wall_jump")
	var state_run: LimboState = RunState.new().named("run")
	var state_down: LimboState = DownState.new().named("down")
	var state_dash_attack: LimboState = DashAttackState.new().named("dash_attack")
	var state_jump_attack: LimboState = JumpAttackState.new().named("jump_attack")
	var state_prepare_attack: LimboState = PrepareAttackState.new().named("prepare_attack")
	var state_hold_throw_attack: LimboState = HoldThrowAttackState.new().named("hold_throw_attack")
	var state_shade: LimboState = ShadeState.new().named("shade")

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
	main_state_machine.add_child(state_busy)
	
	main_state_machine.initial_state = state_idle
	
	#ENTER DEAD STATE
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_dead, to_dead)
	
	#ENTER BUSY STATE
	main_state_machine.add_transition(main_state_machine.ANYSTATE, state_busy, to_busy)
	
	#ENTER IDLE STATE
	main_state_machine.add_transition(state_walk, state_idle, to_idle)
	main_state_machine.add_transition(state_run, state_idle, to_idle)
	main_state_machine.add_transition(state_jump, state_idle, to_idle)
	main_state_machine.add_transition(state_jump_attack, state_idle, to_idle)
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
	main_state_machine.add_transition(state_busy, state_idle, to_idle)
	
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
