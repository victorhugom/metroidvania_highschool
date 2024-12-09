class_name DestroyableObjectContainer extends Sprite2D

const DESTROYABLE_OBJECT_PART = preload("res://_starter_content/destroyable_object/destroyable_object_part.tscn")

@export var destruction_power:= Vector2(1,1)
@export var collision_offset: Vector2 = Vector2()

@export_category("Textures")
@export var texture_pieces: Array[Texture2D] = []:
	set(value):
		texture_pieces = value
		if is_node_ready():
			create_parts()
	get:
		return texture_pieces
@export var texture_broken: Texture2D

var destroyable_object_parts: Array[DestroyableObjectPart] = []

func _ready() -> void:
	create_parts()

func destroy(damager_global_position) -> void:
	# Hide the original object
	texture = texture_broken

	for part in destroyable_object_parts:
		part.destruction_power = destruction_power
		part.global_position = global_position
		part.destroy(damager_global_position)

func create_parts() -> void:
	
	for part in destroyable_object_parts:
		part.queue_free()
	destroyable_object_parts = []
	
	for texture_piece in texture_pieces:
		var new_destroyable_part: DestroyableObjectPart = DESTROYABLE_OBJECT_PART.instantiate()
		
		new_destroyable_part.texture = texture_piece
		new_destroyable_part.visible = false
	
		destroyable_object_parts.append(new_destroyable_part)
		add_child(new_destroyable_part)
