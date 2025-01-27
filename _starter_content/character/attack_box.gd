class_name AttackBox extends Area2D

enum DamageType {Default, Acid, Explosion}

@onready var timer: Timer = $Timer

signal hit_area(damage: int, area_hit: Area2D)
signal hit_body(damage: int, body_hit: Node2D)
signal parried(character: CharacterBody2D)

## amount of damage that this box doe
@export var damage: int
@export var damage_interval: float
@export var damage_type: DamageType

var damaged_entities = []
var started: bool = true

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_damage_interval_timeout)

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
	
	if not started and damage_interval > 0:
		timer.wait_time = damage_interval
		timer.start()
	
	if area not in damaged_entities:
		damaged_entities.append(area)
		area.damage(damage, self)
		hit_area.emit(damage, area)
		
## Occours when entering a body that can be hit
func _on_body_entered(body: Node2D):
	
	if not started and damage_interval > 0:
		timer.wait_time = damage_interval
		timer.start()
	
	if body not in damaged_entities and body.has_method("damage"):
		damaged_entities.append(body)
		body.damage(damage, self)
		hit_body.emit(damage, body)
		
func _on_damage_interval_timeout():
	
	if damaged_entities.size() == 0:
		timer.stop()
		started = false
	else:
		for item in damaged_entities:
			if item.has_method("damage"):
				item.damage(damage, self)
				if item is Node2D:
					hit_body.emit(damage, item)
				elif item is Area2D:
					hit_area.emit(damage, item)
