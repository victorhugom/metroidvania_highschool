@tool
class_name InteractableAnimatedSprited2d extends AnimatedSprite2D

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D


#region Interactable
@export var disabled := false
## run only when enter the area, usable for detroy things when stepping in it
@export var run_only_on_enter:= false

@export_category("Audio Settings")
## audio played when goes to state a
@export var audio_stream_enter: AudioStream
## audio played when goes to state b
@export var audio_stream_leave: AudioStream
#endregion

# Define custom properties for collision layers and masks
var audio_stream_player_2d: AudioStreamPlayer2D
var collision_layers = 0 #setget set_collision_layers
var collision_masks = 0 #setget set_collision_masks
var played = false

@export_category("Collision")
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

func _ready() -> void:
	
	audio_stream_player_2d = AudioStreamPlayer2D.new()
	get_tree().root.add_child.call_deferred(audio_stream_player_2d)
	
	assert(sprite_frames.has_animation("enter"), "'enter' animation not found, create it")

	var texture: Texture2D = sprite_frames.get_frame_texture("enter", 0)
	
	# Set the new size
	var texture_size = Vector2(texture.get_size().x, texture.get_size().y)
	var rect_shape = collision_shape.shape as RectangleShape2D 
	rect_shape.size = texture_size
	
	area_2d.collision_layer = collision_layers  # Update the internal collision layer
	area_2d.collision_mask = collision_masks  # Update the internal collision mask
	
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
func _on_body_entered(_body: Node2D) -> void:
	if run_only_on_enter && played:
		return
		
	played = true
	sprite_frames.set_animation_loop("enter", false)
	play("enter")
	
	if !audio_stream_player_2d.is_playing() && audio_stream_enter: 
		audio_stream_player_2d.stream = audio_stream_enter 
		audio_stream_player_2d.play(0)

func _on_body_exited(_body: Node2D) -> void:
	if sprite_frames.has_animation("leave"):
		sprite_frames.set_animation_loop("enter", false)
		play("leave")
		
		if !audio_stream_player_2d.is_playing() && audio_stream_leave: 
			audio_stream_player_2d.stream = audio_stream_leave 
			audio_stream_player_2d.play(0)
