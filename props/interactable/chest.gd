class_name Chest extends Node2D

@onready var interactable_switch: InteractableSwitch = $InteractableSwitch
@onready var money_dropper: MoneyDropper = $MoneyDropper


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_switch.interact.connect(_on_interact)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_interact(body: Node2D):
	money_dropper.drop()
