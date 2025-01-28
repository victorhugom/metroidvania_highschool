class_name MenuItem extends Button

@export var inventory_item: InventoryItem
@export var selected: bool:
	get:
		return selected
	set(value):
		selected = value
		update_style()

var style

func _init(_inventory_item: InventoryItem = null, _selected: bool = false):
	inventory_item = _inventory_item
	selected = _selected	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	style = get("theme_override_styles/normal")
	
	style = StyleBoxFlat.new()
	add_theme_stylebox_override("normal", style)
	
	style.draw_center = false
	
	style.border_color = "203310"
	style.border_blend = true
	
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	
	icon = load(inventory_item.icon)
	
	update_style()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_style():
	
	var border_width = 2
	if selected:
		border_width = 5

	if style:
		style.border_width_left = border_width
		style.border_width_top = border_width
		style.border_width_right = border_width
		style.border_width_bottom = border_width
