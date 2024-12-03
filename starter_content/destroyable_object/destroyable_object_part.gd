class_name DestroyableObjectPart extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var texture: Texture2D
@export var destruction_power:= Vector2(1,1)

var force: Vector2 = Vector2.ZERO
var destroying:= false

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	sprite_2d.texture = texture

func _physics_process(_delta: float) -> void:
	if destroying:
		apply_central_impulse(force)
	
func destroy(colider_position: Vector2) -> void:
	if destroying: 
		return
		
	_update_collision_side()
	visible = true
	var x_force = -(colider_position - global_position)
	
	force = Vector2(randf_range(x_force.x/2,x_force.x) * destruction_power.x, randi_range(-64, -80) * destruction_power.y) 
	destroying = true
	timer.start()
	
func _update_collision_side():
	if texture == null:
		return
	# Set the new size
	var texture_size = Vector2(sprite_2d.texture.get_size().x, sprite_2d.texture.get_size().y)
	var rect_shape = collision_shape.shape as RectangleShape2D 
	rect_shape.size = texture_size

func _on_timer_timeout() -> void:
	timer.stop()
	destroying = false
