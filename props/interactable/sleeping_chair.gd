extends Node2D

@onready var interactable: Interactable = $Interactable
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var player: Player = %Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.interact.connect(_on_interactable_interact)
	#animation_player.animation_finished.connect(_on_animation_player_animation_finished)

func _on_interactable_interact(body: Node2D):
	
	if LevelsVars.SLEEPING == true:
		player_sprite.visible = true
		animation_player.play("wakeup")
		LevelsVars.wakeup()
	else:
		player.visible = false
		player_sprite.visible = true
		animation_player.play("sleep")
		animation_player.queue("sleeping")
		LevelsVars.sleep()
		
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "wakeup":
		player.visible = true
	if anim_name == "sleep":
		player.visible = true

func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	if old_name == "sleep":
		player.visible = true
