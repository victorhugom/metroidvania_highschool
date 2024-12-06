class_name Throwable extends CharacterBody2D

@export var explosion: PackedScene
# Variables for the throw
@export var throw_angle = 45.0 # Throw angle in degrees
@export var throw_speed = 400.0: # Throw speed
	get():
		return throw_speed
	set(value):
		throw_speed = mini(value, 400)

var hit_something = false
var can_move = false

func _ready():
	pass
	
func _physics_process(delta):
	
	if not can_move:
		return
	
	# If the object has hit something, stop horizontal movement
	if hit_something:
		velocity.x = 0
		
	if is_on_floor():
		velocity.y = 0
		_create_explosion()
	else:
		velocity += get_gravity() * delta
		move_and_slide()
		
func throw(direction: String, angle:= 45, speed:= 400):
	
	throw_speed = speed
	throw_angle = angle
	
	var radians = deg_to_rad(throw_angle)
	velocity.y = -throw_speed * sin(radians) # Negative because y-axis is downwards
	
	if direction == "left":
		velocity.x = -throw_speed * cos(radians)
	else:
		velocity.x = throw_speed * cos(radians)
		
	can_move = true

func _on_body_entered(_body):
	hit_something = true

func _on_area_entered(_area):
	hit_something = true
	
func _create_explosion():
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = global_position
	var first_node = get_tree().current_scene.get_child(0)
	(first_node as Node2D).add_sibling(new_explosion)
	
	var tween = create_tween() 
	tween.tween_property(self, "modulate:a", 0.0, .2) 
	tween.finished.connect(_on_tween_finished)
	
func _on_tween_finished():
	queue_free()
