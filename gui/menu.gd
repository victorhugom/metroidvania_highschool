class_name MenuPhone extends CanvasLayer

const MENU_ITEM = preload("res://gui/menu_item.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rich_text_label_time: RichTextLabel = $RichTextLabel_Time
@onready var menu_container: HFlowContainer = $MenuContainer
@onready var sub_container: HFlowContainer = $SubContainer
@onready var selected_item_label: RichTextLabel = $CenterContainer/SelectedItemLabel
@onready var money_label: RichTextLabel = $MoneyLabel

var is_menu_open:bool = false
var item_selected: MenuItem
var item_selected_index: int = 0
var menu_items: Array[Node]
var current_menu: HFlowContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_menu = menu_container
	menu_items = current_menu.get_children()
	item_selected = menu_items[0]
	item_selected.selected = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rich_text_label_time.text = get_current_time()

func get_current_time() -> String:
	var now = Time.get_time_dict_from_system()
	return "%d:%d:%d" % [now.hour, now.minute, now.second]
	
func _input(event: InputEvent) -> void:
	
	if event.is_action_released("ui_menu"):
		if is_menu_open:
			animation_player.play("hide_phone")
			is_menu_open = false
			get_tree().paused = false
		else:
			animation_player.play("show_phone")
			is_menu_open = true
			get_tree().paused = true
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
			select_menu_item(item_selected.inventory_item.item_type)
			
func select_item(item_index:int):

	item_selected.selected = false
	item_selected = menu_items[item_index]
	item_selected.selected = true
	
	selected_item_label.text = item_selected.inventory_item.description

func select_menu_item(menu_item_type: String):
	
	item_selected_index = 0
	var player: Player = get_tree().get_nodes_in_group("player")[0]
	
	if menu_item_type == "back":
		menu_container.visible = true
		sub_container.visible = false
		current_menu = menu_container
		menu_items = current_menu.get_children()
		select_item(item_selected_index)
		return
	if current_menu == sub_container:
		return
		#TODO: use item
	
	var inventory = player.inventory
	var inventory_items = inventory.get_items_grouped()
	
	for child in sub_container.get_children():
		sub_container.remove_child(child)
	
	var back_item = MENU_ITEM.instantiate()
	back_item.inventory_item = InventoryItem.new("", "back", "Back", "Back", "res://assets/gui/icons/back_icon.png")
	sub_container.add_child(back_item)
	
	for key in inventory_items:
		if key == menu_item_type:
			var items = inventory.has_item(key)
			for item_data in items:
				var new_item = MENU_ITEM.instantiate()
				new_item.inventory_item = item_data
				sub_container.add_child(new_item)
			
	menu_container.visible = false
	sub_container.visible = true
	current_menu = sub_container
	menu_items = current_menu.get_children()
	select_item(item_selected_index)
