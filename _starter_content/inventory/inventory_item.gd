class_name InventoryItem extends Resource

@export_group("Display Data")
@export var item_id: String
@export var item_type: String
@export var display_name: String
@export var description: String

@export_group("Custom Data")
@export var resource: Resource

func to_dict() -> Dictionary:
	return {
		"item_id": item_id,
		"item_type": item_type,
		"display_name": display_name,
		"description": description,
	}
