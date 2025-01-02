extends Node2D

@onready var interactable_switch: InteractableSwitch = $InteractableSwitch
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _on_interactable_switch_interact(body: Node2D) -> void:
	
	var player = body as Player
	interactable_switch.disabled = true
	player.health.reset_health()
	
	timer.stop()
	timer.start()
	
func _on_timer_timeout():
	interactable_switch.disabled = false
	interactable_switch.go_to_sate_a()
