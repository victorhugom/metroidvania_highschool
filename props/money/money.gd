class_name Money extends RigidBody2D

@onready var floor_collision: Area2D = $FloorCollision
@onready var player_collision: Area2D = $PlayerCollision

# Variables to control the fall behavior
@export var min_sway_amplitude: float = 50 # Maximum horizontal distance for sway
@export var max_sway_amplitude: float = 100 # Maximum horizontal distance for sway
@export var min_sway_frequency: float = 2.0 # Oscillation speed
@export var max_sway_frequency: float = 4.0 # Oscillation speed
@export var max_angular_speed: float = 5 # Control rotation speed
@export var follow_speed: float = 200 # Speed at which the leaf moves toward the target

var item_data: InventoryItem = InventoryItem.new("", "money", "Sakura", "Folha de Sakura")

var follow_target: Node2D = null
var has_hit_floor: bool = false

# Internal timer for the sine wave
var sway_timer: float = 0.0

func _ready():
	
	floor_collision.area_entered.connect(_on_floor_area_entered)
	floor_collision.body_entered.connect(_on_floor_body_entered)
	
	player_collision.body_entered.connect(_on_player_body_entered)
	
	# Set initial linear velocity
	angular_velocity = randf_range(10, max_angular_speed) * (1 if randf() < 0.5 else -1)

func _process(delta):
	
	if has_hit_floor: 
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		freeze = true
		return
	
	# Update the sway timer
	sway_timer += delta * randf_range(min_sway_frequency, max_sway_frequency)

	# Calculate the horizontal sway using a sine wave
	var sway_offset = randf_range(min_sway_amplitude, max_sway_amplitude) * sin(sway_timer)

	if follow_target:
		# Move toward the target position
		var direction = (follow_target.global_position - global_position).normalized()
		# Blend sway into the movement toward the target
		linear_velocity = Vector2(sway_offset, linear_velocity.y) + direction * follow_speed
	else:
		# Apply the sway directly when not following a target
		linear_velocity.x = sway_offset
		
func _on_floor_area_entered(_area: Area2D):
	has_hit_floor = true
	
func _on_floor_body_entered(_body: Node2D):
	has_hit_floor = true
	
func _on_player_body_entered(body:Node2D):
	
	var inventory = body.get_node("Inventory") as Inventory
	assert(inventory != null, "Error: Inventory not found, check if inventory is in the actor, is in the root and with the name 'Inventory' case sensitive")
	inventory.add_item(item_data)
	
	queue_free()
		
func set_follow_target(target: Node2D):
	follow_target = target
