class_name Interactable extends Area2D

signal interact(body: Node2D)
signal begin_focus(body: Node2D)
signal end_focus(body: Node2D)

const INTERACTION_UI = preload("res://starter_content/interactable/ui/interaction_ui.tscn")

@export var interact_message:= "Interagir":
	set(value):
		interact_message = value
		
		if interactor != null:
			interaction_ui.show_interaction(interact_message)
	get:
		return interact_message
		
@export var cannot_interact_message:= "Não pode interagir":
	set(value):
		cannot_interact_message = value
	get:
		return cannot_interact_message

## If true disables interaction after the first one
@export var can_interact_once:= false
@export var disabled := false

@export_category("Requires Key")
@export var requires_item:=false
@export var required_item_type: String
@export var required_item_quantity:= 1

@export_category("Audio Settings")
@export var interact_audio_stream: AudioStream

var audio_stream_player_2d: AudioStreamPlayer2D
var in_interaction_area:= false
var interactor: Node2D
var interaction_ui: InteractionUI

func _ready() -> void:
	audio_stream_player_2d = AudioStreamPlayer2D.new()
	audio_stream_player_2d.global_position = global_position
	get_tree().root.add_child.call_deferred(audio_stream_player_2d)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func can_interact() -> bool:
	
	if disabled:
		return false
	
	if requires_item == false:
		return true
	
	var inventory = interactor.get_node("Inventory") as Inventory
	assert(inventory != null, "Error: Inventory not found, check if inventory is in the actor root and with the name 'Inventory' case sensitive")
	
	var required_item = inventory.has_item(required_item_type)
	
	return required_item.size() > 0 && required_item.size() >= required_item_quantity

func _on_body_entered(body: Node2D) -> void:
	
	if get_tree().root.has_node("InteractionUi"):
		interaction_ui = get_tree().root.get_node("InteractionUi")
	else:
		interaction_ui = INTERACTION_UI.instantiate()
		get_tree().root.add_child(interaction_ui)
		
	interactor = body
	
	in_interaction_area = true
	
	if can_interact():
		interaction_ui.show_interaction(interact_message)
	else:
		interaction_ui.show_interaction(cannot_interact_message)
	
	begin_focus.emit(body)

func _on_body_exited(body: Node2D) -> void:
	interactor = null

	in_interaction_area = false
	
	interaction_ui.hide_interaction()
	
	end_focus.emit(body)
	
func _input(event):
	if interactor and event.is_action_pressed("ui_interact") and can_interact():
		if can_interact_once:
			disabled = true  # Desabilita interação após a primeira interação
		
		audio_stream_player_2d.stop()
		audio_stream_player_2d.global_position = global_position
		if !audio_stream_player_2d.is_playing() && interact_audio_stream: 
			audio_stream_player_2d.stream = interact_audio_stream 
			audio_stream_player_2d.play(0)
			
		interact.emit(interactor)
		
func _exit_tree() -> void:
	
	if interact_audio_stream:
		var tween = get_tree().create_tween()
		tween.tween_callback(audio_stream_player_2d.queue_free).set_delay(interact_audio_stream.get_length())
	else:
		audio_stream_player_2d.queue_free()
