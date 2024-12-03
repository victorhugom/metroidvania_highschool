class_name HurtBox extends Area2D

signal damaged(damage:int)
signal hurtbox_area_entered(area: Area2D)

@export var health: Health
## Set false if player cannot be hurt, by setting this true when an `AttackBox`
## hits the player will not do damage
@export var can_be_hurt: bool = true

func _ready() -> void:
	assert(health != null, "param:health not set, health needed")
	area_entered.connect(_on_area_entered)

##Occours when a `AttackBox` area enter this zone
##1. emits `hurtbox_area_entered`
##2. decrease health
##3. emits `damaged`
func _on_area_entered(area: Area2D) -> void:
	
	hurtbox_area_entered.emit(area)
	
	if not can_be_hurt:
		return
	
	if area is AttackBox:
		var attack_box = area as AttackBox
		var damage = attack_box.damage
		
		print_rich("[color=red][b] Hurt Box Take Damage:[/b][/color]  %s" %damage)
		health.decrease_health(damage)
		damaged.emit(damage)
