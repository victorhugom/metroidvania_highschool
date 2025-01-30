@tool
class_name VendingMachineItem extends VBoxContainer

@export var item_sprite: Texture2D:
	set(value):
		item_sprite = value
		update_sprite()

@export var item_price: int:
	set(value):
		item_price = value
		update_label()

@export var selected: bool:
	get:
		return selected
	set(value):
		selected = value
		update_style()
		
@export var item_name: String
@export var description: String

var sprite_2d: Sprite2D
var rich_text_label: RichTextLabel

func _ready() -> void:
	# Initialize nodes
	sprite_2d = $CenterContainer/Sprite2D
	rich_text_label = $CenterContainer2/RichTextLabel

	# Update UI with initial values
	update_sprite()
	update_label()
	update_style()

func update_sprite() -> void:
	if sprite_2d and item_sprite:
		sprite_2d.texture = item_sprite

func update_label() -> void:
	if rich_text_label:
		rich_text_label.text = "$ %s" %item_price

func update_style() -> void:
	if sprite_2d:
		sprite_2d.frame = 1 if selected else 0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		# Only run in the editor
		update_sprite()
		update_label()
		update_style()
