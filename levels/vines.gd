extends Node2D

@onready var hurt_box: HurtBox = $HurtBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurt_box.damaged.connect(_on_damaged)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_damaged(damage: int, damager: AttackBox):
	
	if damager.damage_type == AttackBox.DamageType.Acid:
		queue_free()
