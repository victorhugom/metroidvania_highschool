class_name AttackBox extends Area2D

signal hit_area(damage: int, area_hit: Area2D)
signal hit_body(damage: int, body_hit: Node2D)
signal parried(character: CharacterBody2D)

## amount of damage that this box doe
@export var damage: int

var damaged_entities = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func start_attack():
	damaged_entities = []
	monitorable = true
	monitoring = true
	
func end_attack():
	damaged_entities = []
	monitorable = false
	monitoring = false
	
func parry(character: CharacterBody2D):
	parried.emit(character)
	
## Occours when entering a area that can be hit
func _on_area_entered(area: Area2D):
	
	if area not in damaged_entities:
		damaged_entities.append(area)
		area.damage(damage, self)
		hit_area.emit(damage, area)
		
## Occours when entering a body that can be hit
func _on_body_entered(body: Node2D):
	
	if body not in damaged_entities and body.has_method("damage"):
		damaged_entities.append(body)
		body.damage(damage, self)
		hit_body.emit(damage, body)
