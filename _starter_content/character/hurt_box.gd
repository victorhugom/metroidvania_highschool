class_name HurtBox extends Area2D

signal damaged(damage:int, damager:Area2D)

@export var health: Health
## Set false if player cannot be hurt, by setting this true when an `AttackBox`
## hits the player will not do damage
@export var can_be_hurt: bool = true
## Don't get for this time after getting hit before
@export var iframe_seconds : float = .5

var current_iframe: float = 0

func _ready() -> void:
	assert(health != null, "param:health not set, health needed")
	
func _process(delta: float) -> void:
	
	if current_iframe > 0:
		current_iframe -= delta
		
##Occours when a `AttackBox` area enter this zone
##1. decrease health
##2. emits `damaged`
func damage(damage_value:int, damager:Area2D):
	
	print_rich("[color=red][b] Hurt Box Take Damage:[/b][/color]  %s" %damage_value)
	health.decrease_health(damage_value)
	damaged.emit(damage_value, damager)
