extends LevelController

@onready var door: InteractableSwitch = $Door
@onready var boss_enemy: BaseBoss = $BossEnemy

var minions_spawn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss_enemy.health.health_changed.connect(_on_boss_health_change)
	
	var tween = get_tree().create_tween()
	tween.tween_callback(disable_minions).set_delay(5)
	
func disable_minions():
	var minions = get_tree().get_nodes_in_group("enemy_spawn")
	for minion: BaseEnemy in minions:
		minion.is_enabled = false

func _on_boss_room_trigger_area_entered(area: Area2D) -> void:
	door.disabled = true
	boss_enemy.is_enabled = true
	var player:Player = get_tree().get_nodes_in_group("player")[0]
	player.follow_camera.update_zoom(Vector2(1.5,1.5))	
	
func _on_boss_health_change(current_health: int):
	
	if current_health < 15 and minions_spawn == false:
		minions_spawn = true
		var minions = get_tree().get_nodes_in_group("enemy_spawn")
		
		for minion: BaseEnemy in minions:
			minion.is_enabled = true
