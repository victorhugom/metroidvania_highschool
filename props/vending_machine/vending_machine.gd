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
var original_camera_zoom: Vector2
var original_camera_position: Vector2

const VENDING_MACHINE_ITEM = preload("res://props/vending_machine/vending_machine_item.tscn")

const COFFEE = preload("res://props/vending_machine/vending_machine_items/coffee.tres")
const ENERGY_DRINK = preload("res://props/vending_machine/vending_machine_items/energy_drink.tres")
const SODA = preload("res://props/vending_machine/vending_machine_items/soda.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_switch.interact.connect(_on_interactable_interact)
	initialize_vending_machine_items()

func initialize_vending_machine_items():
	var vending_machine_item_soda = VENDING_MACHINE_ITEM.instantiate()
	vending_machine_item_soda.item_name = SODA.display_name
	vending_machine_item_soda.description = SODA.description
	vending_machine_item_soda.item_price = 100
	vending_machine_item_soda.item_sprite = preload("res://assets/props/itens/drink_bottle2_icon.png")
	
	var vending_machine_item_energy_drink = VENDING_MACHINE_ITEM.instantiate()
	vending_machine_item_energy_drink.item_name = ENERGY_DRINK.display_name
	vending_machine_item_energy_drink.description = ENERGY_DRINK.description
	vending_machine_item_energy_drink.item_price = 200
	vending_machine_item_energy_drink.item_sprite = preload("res://assets/props/itens/drink_bottle1_icon.png")

	var vending_machine_item_coffee = VENDING_MACHINE_ITEM.instantiate()
	vending_machine_item_coffee.item_name = COFFEE.display_name
	vending_machine_item_coffee.description = COFFEE.description
	vending_machine_item_coffee.item_price = 300
	vending_machine_item_coffee.item_sprite = preload("res://assets/props/itens/drink_can_icon.png")

	menu_container.add_child(vending_machine_item_soda)
	menu_container.add_child(vending_machine_item_energy_drink)
	menu_container.add_child(vending_machine_item_coffee)

	menu_items = menu_container.get_children()
	item_selected = menu_items[0]
	item_selected.selected = true

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
			buy_selected_item()
		if event.is_action_pressed("ui_cancel"):
			exit()
			
func select_item(item_index:int):

	item_selected.selected = false
	item_selected = menu_items[item_index]
	item_selected.selected = true
	
	item_name.text = item_selected.item_name
	item_description.text = item_selected.description
	
func buy_selected_item():
	var money_item = player.inventory.has_item("money")
	
	if money_item.size() >= item_selected.item_price:
		match item_selected.item_name:
			"Energy Drink":
				player.inventory.add_item(ENERGY_DRINK)
			"Soda":
				player.inventory.add_item(SODA)
			"Coffee":
				player.inventory.add_item(COFFEE)
		player.inventory.remove_item_by_type_with_quantity("money", item_selected.item_price)
	else:
		print_debug("Cannot buy: not enough money")
		
func _on_interactable_interact(_body: Node2D):
	player.is_busy = true
	player.global_position = player_position.global_position

	original_camera_zoom = player.follow_camera.zoom
	original_camera_position = player.follow_camera.global_position

	player.follow_camera.update_zoom(Vector2(7.2, 7.2))
	player.follow_camera.global_position = Vector2(global_position.x, global_position.y - 50)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "is_menu_open", true, 1.5)

func exit():
	is_menu_open = false

	player.follow_camera.update_zoom(original_camera_zoom)
	player.follow_camera.global_position = original_camera_position
	var tween = get_tree().create_tween()
	tween.tween_callback(Callable(self, "_set_player_busy")).set_delay(1.5)

func _set_player_busy():
	player.is_busy = false
