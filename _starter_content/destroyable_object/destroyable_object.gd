@tool
class_name DestroyableObject extends Node2D

signal destroyed()

@onready var destroyable_object_container: DestroyableObjectContainer = $DestroyableObjectContainer
@onready var hurt_box: HurtBox = $HurtBox
@onready var health: Health = $Health
@onready var collision_shape: CollisionShape2D = $HurtBox/CollisionShape2D

@export var life:= 1
@export var destruction_power= Vector2(1,1)
@export var collision_offset: Vector2 = Vector2()

@export_category("Textures")
@export var texture_full: Texture2D
@export var texture_broken: Texture2D
@export var texture_pieces: Array[Texture2D] = []

func _set(property: StringName, value: Variant) -> bool:
	if property == "collision_offset":
		collision_offset = value
		_update_collision_offset()
		return true
	if property == "texture_full":
		texture_full = value
		destroyable_object_container.texture = value
		return true
	return false

func _get(property: StringName):
	if property == "collision_offset":
		return collision_offset
	if property == "texture_full":
		return texture_full
	return null
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): 
		_update_collision_offset()
		_update_collision_side()
		destroyable_object_container.texture = texture_full
		
func _update_collision_offset():
	if collision_shape:
		collision_shape.position = collision_offset
		
func _update_collision_side():
	if destroyable_object_container.texture == null:
		return
	# Set the new size
	var texture_size = Vector2(destroyable_object_container.texture.get_size().x, destroyable_object_container.texture.get_size().y)
	var rect_shape = collision_shape.shape as RectangleShape2D 
	rect_shape.size = texture_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	health.max_health = 1
	health.health_empty.connect(destroy)
	
	destroyable_object_container.texture = texture_full
	destroyable_object_container.texture_broken = texture_broken
	destroyable_object_container.texture_pieces = texture_pieces
	destroyable_object_container.destruction_power = destruction_power
	
func destroy():
	hurt_box.can_be_hurt = false
	hurt_box.set_deferred("monitoring", false)
	hurt_box.set_deferred("monitorable", false)
	
	destroyable_object_container.destroy(global_position)
	destroyed.emit()
