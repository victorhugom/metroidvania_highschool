class_name BaseEnemy extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var ray_cast_2d_eyes: RayCast2D = $RayCast2DEyes
@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
@onready var ray_cast_2d_right: RayCast2D = $RayCast2DRight
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed = 64
@export var dodge_distance = 128

var origin_position = Vector2.ZERO
var has_floor = true
var direction = "right"
var player_in_sight: CharacterBody2D

func _ready():
	origin_position = global_position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.x > 0:
		direction = "right"
		sprite_2d.flip_h = false
		animation_player.play("walk")
		ray_cast_2d_eyes.target_position = abs(ray_cast_2d_eyes.target_position)
	elif velocity.x < 0:
		direction = "left"
		sprite_2d.flip_h = true
		animation_player.play("walk")
		ray_cast_2d_eyes.target_position = -abs(ray_cast_2d_eyes.target_position)
	else:
		animation_player.play("idle")

	if velocity.x < 0 and not ray_cast_2d_left.is_colliding():
		has_floor = false
		stop()
	elif velocity.x > 0 and not ray_cast_2d_right.is_colliding():
		has_floor = false
		stop()
	else:
		has_floor = true
		
	move_and_slide()
		
func move(target_position) -> void:
	
	var move_direction = (target_position - global_position).normalized()
	if move_direction.x > 0:
		velocity = Vector2(1, 0) * speed
	else:
		velocity = Vector2(-1, 0) * speed
		
func stop() -> void:
	velocity = Vector2.ZERO

func dodge() -> void:
	position += Vector2(randf() * dodge_distance, randf() * dodge_distance)
	
func check_for_player():
	if ray_cast_2d_eyes.is_colliding():
		player_in_sight = ray_cast_2d_eyes.get_collider()
	else:
		player_in_sight = null
			
