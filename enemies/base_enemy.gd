class_name BaseEnemy extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
@onready var ray_cast_2d_right: RayCast2D = $RayCast2DRight
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed = 64
@export var dodge_distance = 128

var origin_position = Vector2.ZERO
var has_floor = true

func _ready():
	origin_position = global_position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.x > 0:
		sprite_2d.flip_h = false
		animation_player.play("walk")
	elif velocity.x < 0:
		sprite_2d.flip_h = true
		animation_player.play("walk")
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
	
	var direction = (target_position - global_position).normalized()
	if direction.x > 0:
		velocity = Vector2(1, 0) * speed
	else:
		velocity = Vector2(-1, 0) * speed
		
func stop() -> void:
	velocity = Vector2.ZERO

func dodge() -> void:
	position += Vector2(randf() * dodge_distance, randf() * dodge_distance)
