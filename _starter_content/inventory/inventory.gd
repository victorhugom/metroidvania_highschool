class_name Inventory extends Node2D

@export var inventory_data_save_path:= "user://inventory_data.json"
@export var starter_items: Array[InventoryItem]

signal item_added(item: InventoryItem)

var inventory_items: Array[InventoryItem]

func _ready() -> void:
	inventory_items = _load_data()

func add_item(item: InventoryItem):
	inventory_items.append(item)
	item_added.emit(item)
	
	_save_data()
	
func has_item(item_type: String) -> Array[InventoryItem]:
	var items_found: Array[InventoryItem] = []
	for item in inventory_items + starter_items:
		if item.item_type == item_type:
			items_found.append(item)
			
	return items_found

func get_items_grouped()-> Dictionary:
	var grouped_items = {}
	
	for item in inventory_items + starter_items:
		if item.item_type in grouped_items:
			grouped_items[item.item_type] += 1
		else:
			grouped_items[item.item_type] = 1
	
	return grouped_items
	
func _save_data():
	var file := FileAccess.open(inventory_data_save_path, FileAccess.WRITE)
	
	var items_dict = inventory_items.map(func(x:InventoryItem): return x.to_dict())
	file.store_line(JSON.stringify(items_dict))
	
func _load_data() -> Array[InventoryItem]:
	var file := FileAccess.open(inventory_data_save_path, FileAccess.READ)
	
	if file == null:
		print_rich("[color=yellow][b] Inventory data not found [/b][/color]")
		return []
	
	var json := JSON.new()
	json.parse(file.get_line())
	var save_dict := json.get_data() as Array
	var load_items: Array[InventoryItem] = []
	
	for item: Dictionary in save_dict:
		var inventory_item: InventoryItem = InventoryItem.new()
		inventory_item.description = item.description
		inventory_item.display_name = item.display_name
		inventory_item.item_id = item.item_id
		inventory_item.item_type = item.item_type
		inventory_item.resource = Resource.new()
		
		load_items.append(inventory_item)
		
	return load_items
