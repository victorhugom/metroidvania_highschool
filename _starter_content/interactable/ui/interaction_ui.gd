class_name InteractionUI extends CanvasLayer

@onready var rich_text_label: RichTextLabel = $HBoxContainer/CenterContainer/RichTextLabel
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect

@export var interaction_button_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if interaction_button_texture:
		texture_rect.texture = interaction_button_texture
	#hide_interaction()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_interaction(text) -> void:
	visible = true
	rich_text_label.text = text

func hide_interaction() -> void:
	visible = false
