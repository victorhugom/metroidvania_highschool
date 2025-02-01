@tool
class_name VendingMachineItem extends VBoxContainer

@onready var rich_text_label: RichTextLabel = $CenterContainer2/RichTextLabel
@onready var sprite_2d: Sprite2D = $CenterContainer/Sprite2D

var _item_sprite: Texture2D
var _item_price: int
var _selected: bool

@export var item_sprite: Texture2D:
	get:
		return _item_sprite
	set(value):
		_item_sprite = value
		update_sprite()

@export var item_price: int:
	get:
		return _item_price
	set(value):
		_item_price = value
		update_label()

@export var selected: bool:
	get:
		return _selected
	set(value):
		_selected = value
		update_style()

@export var item_name: String
@export var description: String

func _ready() -> void:
	# Update UI with initial values
	update_sprite()
	update_label()
	update_style()

func _process(_delta: float) -> void:
	# Continuously update the UI in the editor
	if Engine.is_editor_hint():
		update_sprite()
		update_label()
		update_style()

func update_sprite() -> void:
	if sprite_2d and _item_sprite:
		sprite_2d.texture = _item_sprite

func update_label() -> void:
	if rich_text_label:
		rich_text_label.text = "$ %s" % _item_price

func update_style() -> void:
	if sprite_2d:
		sprite_2d.frame = 1 if _selected else 0
