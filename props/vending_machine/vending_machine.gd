extends Node2D

@onready var player: Player = %Player
@onready var interactable_switch: InteractableSwitch = $InteractableSwitch
@onready var player_position: Marker2D = $PlayerPosition
@onready var menu_container: HFlowContainer = $MenuContainer
@onready var item_name: RichTextLabel = $ItemName
@onready var item_description: RichTextLabel = $CenterContainer/ItemDescription

var is_menu_open:bool = false
var item_selected: VendingMachineItem
var item_selected_index: int = 0
var menu_items: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_switch.interact.connect(_on_interactable_interact)
	menu_items = menu_container.get_children()
	item_selected = menu_items[0]
	item_selected.selected = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	
	if is_menu_open:
		if event.is_action_released("ui_left"):
			item_selected_index -= 1
			if item_selected_index < 0: item_selected_index = 0
			select_item(item_selected_index)

		if event.is_action_released("ui_right"):
			item_selected_index += 1
			if item_selected_index > menu_items.size() - 1: item_selected_index = 0
			select_item(item_selected_index)
		if event.is_action_pressed("ui_select"):
			print_debug("buy")
			#select_menu_item(item_selected.inventory_item.item_type)
			
func select_item(item_index:int):

	item_selected.selected = false
	item_selected = menu_items[item_index]
	item_selected.selected = true
	
	item_name.text = item_selected.item_name
	item_description.text = item_selected.description
	
func _on_interactable_interact(_body: Node2D):
	is_menu_open = true
	player.is_busy = true
	player.global_position = player_position.global_position
	player.follow_camera.update_zoom(Vector2(7.2, 7.2))
	player.follow_camera.global_position = Vector2(global_position.x, global_position.y - 50) 
