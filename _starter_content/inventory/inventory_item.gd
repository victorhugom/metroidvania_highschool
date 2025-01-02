class_name InventoryItem extends Resource

@export_group("Display Data")
@export var item_id: String
@export var item_type: String
@export var display_name: String
@export var description: String

@export_group("Custom Data")
@export var resource: Resource

func _init(_item_id: String = "", _item_type: String = "", _display_name: String = "", \
			_description: String = "", _resource: Resource = null):
	
	item_id =  str(ResourceUID.create_id()) if not _item_id else _item_id
	item_type = _item_type
	display_name = _display_name
	description = _description
	resource = _resource
	
func to_dict() -> Dictionary:
	return {
		"item_id": item_id,
		"item_type": item_type,
		"display_name": display_name,
		"description": description,
	}
