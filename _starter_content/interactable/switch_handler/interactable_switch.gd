@tool
class_name InteractableSwitch extends Sprite2D

signal interact(body: Node2D)

@export var animation_player: AnimationPlayer
@onready var collision_shape: CollisionShape2D = $Interactable/CollisionShape2D

#region Interactable
@onready var interactable: Interactable = $Interactable
@export var interact_message_a:= "Ativar"
@export var interact_message_b:= "Reverter"
@export var cannot_interact_message:= "Não pode interagir"
@export var can_interact_once:= false
@export var disabled := false

@export_category("Requires Key")
@export var requires_item:=false
@export var required_item_type: String
@export var required_item_quantity:= 1

@export_category("Audio Settings")
## audio played when goes to state a
@export var audio_stream_a: AudioStream
## audio played when goes to state b
@export var audio_stream_b: AudioStream
#endregion

# Define custom properties for collision layers and masks
var collision_layers = 0 #setget set_collision_layers
var collision_masks = 0 #setget set_collision_masks
var current_state:= "state_a"

@export_category("Collision")

@export var collision_offset: Vector2 = Vector2()
# Override _get_property_list to add custom properties to the editor
func _get_property_list() -> Array:
	var properties: Array = []
	properties.append({
		"name": "collision_layers",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_LAYERS_2D_PHYSICS,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	properties.append({
		"name": "collision_masks",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_LAYERS_2D_PHYSICS,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	return properties

func _set(property: StringName, value: Variant) -> bool:
	if property == "collision_offset":
		collision_offset = value
		update_collision_offset()
		return true
	if property == "texture":
		texture = value
	return false

func _get(property: StringName):
	if property == "collision_offset":
		return collision_offset
	return null
	
func update_collision_offset():
	if collision_shape:
		collision_shape.position = collision_offset
		
func update_collision_side():
	if texture == null:
		return
	# Set the new size
	var texture_size = Vector2(texture.get_size().x / hframes, texture.get_size().y / vframes)
	var rect_shape = collision_shape.shape as RectangleShape2D 
	rect_shape.size = texture_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	assert(interactable != null, "interactable not found")
	
	assert(animation_player != null, "animation player not found")
	assert(animation_player.has_animation("state_a"), "state_a not found, create it on animation player")
	assert(animation_player.has_animation("state_b"), "state_b not found, create it on animation player")
	
	interactable.interact.connect(_on_interactable_interacted)
	
	interactable.interact_message = interact_message_a
	interactable.cannot_interact_message = cannot_interact_message
	interactable.can_interact_once = can_interact_once
	interactable.disabled = disabled

	interactable.requires_item = requires_item
	interactable.required_item_type = required_item_type
	interactable.required_item_quantity = required_item_quantity
			
	interactable.collision_layer = collision_layers  # Update the internal collision layer
	interactable.collision_mask = collision_masks  # Update the internal collision mask
	
	update_collision_side()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): 
		update_collision_offset()
		update_collision_side()

func _on_interactable_interacted(body: Node2D) -> void:
	
	# switch interact message and state
	if current_state == "state_a":
		current_state = "state_b"
		interactable.interact_message = interact_message_b
	else:
		current_state = "state_a"
		interactable.interact_message = interact_message_a

	#get audio stream and switch
	var audio_stream = audio_stream_a if current_state == "state_b" else audio_stream_b
	if audio_stream != null:
		interactable.audio_stream = audio_stream
	
	#play animation
	animation_player.play(current_state)
	interact.emit(body)
	
func go_to_sate_a():
	
	if current_state == "state_a":
		return
	
	# switch state
	current_state = "state_a"
	# switch interact message
	interactable.interact_message = interact_message_a
		
	#switch audio stream 
	var audio_stream = audio_stream_a
	if audio_stream != null:
		interactable.audio_stream = audio_stream
	
	#play animation
	animation_player.play(current_state)
	
func go_to_sate_b():
	
	if current_state == "state_b":
		return
	
	# switch state
	current_state = "state_b"
	# switch interact message
	interactable.interact_message = interact_message_b
		
	#switch audio stream 
	var audio_stream = audio_stream_b
	if audio_stream != null:
		interactable.audio_stream = audio_stream
	
	#play animation
	animation_player.play(current_state)
