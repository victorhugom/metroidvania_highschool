class_name Enemy extends CharacterBody2D

signal moving(direction: String, velocity: Vector2)

@export var jump_power: float = -400

var last_direction = "idle"

func _physics_process(delta):
	
	if is_on_wall() and is_on_floor():
		velocity.y = jump_power
	else:
		velocity += get_gravity() * delta
		
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

func move(dir: int, speed: int):
	velocity.x = dir * speed
