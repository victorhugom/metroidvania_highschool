class_name PickableItem extends Node

@onready var interactable: Interactable = $Interactable

@export var inventory_item: InventoryItem
@export var unique_id: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#var inventory_data = Inventory.load_inventory_data()
	#
	#inventory_item.item_id = item_id
	#
	#var item_found = inventory_data.items.filter(func(x): return x.item_id == item_id)
	#if item_found.size() > 0:
		#queue_free()
	
	interactable.interact.connect(_on_interactable_interact)
	interactable.interact_message = "Pegar %s" %inventory_item.display_name
	
## Adds item to inventory when player interacts with it
func interact(body: Node) -> void:
	var inventory = body.get_node("Inventory") as Inventory
	assert(inventory != null, "Error: Inventory not found, check if inventory is in the actor, is in the root and with the name 'Inventory' case sensitive")
	
	inventory.add_item(inventory_item)
	queue_free()

func _on_interactable_interact(body: Node2D) -> void:
	self.interact(body)
