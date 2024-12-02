extends Sprite2D

const DESTROYABLE_OBJECT_PART = preload("res://starter_content/props/destroyable_object_part.tscn")

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@export var texture_pieces: Array[Texture2D] = []

var direction: Vector2 = Vector2.ZERO
var exploding:= false
var destroyable_object_parts: Array[DestroyableObjectPart] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_parts()

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Hide the original object
	texture = null
	collision_shape_2d.set_deferred("disabled", true)

	for part in destroyable_object_parts:
		part.visible = true
		#part.sleeping = false
		part.explode(body.global_position)
	
func _create_parts() -> void:
	for texture_piece in texture_pieces:
		var new_destroyable_part: DestroyableObjectPart = DESTROYABLE_OBJECT_PART.instantiate()
		
		new_destroyable_part.texture = texture_piece
		new_destroyable_part.visible = false
		#new_destroyable_part.sleeping = true
		new_destroyable_part.global_position = global_position
		
		destroyable_object_parts.append(new_destroyable_part)
		get_parent().add_child.call_deferred(new_destroyable_part)
