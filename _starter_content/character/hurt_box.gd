class_name HurtBox extends Area2D

signal damaged(damage:int)
signal hurtbox_area_entered(area: Area2D)

@export var health: Health
## Set false if player cannot be hurt, by setting this true when an `AttackBox`
## hits the player will not do damage
@export var can_be_hurt: bool = true
## Don't get for this time after getting hit before
@export var iframe_seconds : float = .5

var current_iframe: float = 0

func _ready() -> void:
	assert(health != null, "param:health not set, health needed")
	area_entered.connect(_on_area_entered)
	
func _process(delta: float) -> void:
	
	if current_iframe > 0:
		current_iframe -= delta

##Occours when a `AttackBox` area enter this zone
##1. emits `hurtbox_area_entered`
##2. decrease health
##3. emits `damaged`
func _on_area_entered(area: Area2D) -> void:
	
	hurtbox_area_entered.emit(area)
	
	if not can_be_hurt or current_iframe > 0:
		return
	
	if area is AttackBox:
		current_iframe = iframe_seconds
		var attack_box = area as AttackBox
		var damage = attack_box.damage
		
		print_rich("[color=red][b] Hurt Box Take Damage:[/b][/color]  %s" %damage)
		health.decrease_health(damage)
		damaged.emit(damage)
