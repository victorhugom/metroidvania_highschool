class_name DestroyableObjectPart extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer


@export var texture: Texture2D
@export var force_multiplier:= 2.5

var force: Vector2 = Vector2.ZERO
var exploding:= false

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	sprite_2d.texture = texture

func _physics_process(_delta: float) -> void:
	if exploding:
		apply_central_impulse(force)
	
func explode(colider_position: Vector2) -> void:
	if exploding: 
		return
	
	var x_force = colider_position - global_position	
	
	force = Vector2(-randf_range(x_force.x/2,x_force.x), randi_range(-32, -48)) * force_multiplier
	exploding = true
	timer.start()

func _on_timer_timeout() -> void:
	timer.stop()
	exploding = false
