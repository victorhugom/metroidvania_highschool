class_name BaseBoss extends BaseEnemy

func _ready():
	origin_position = global_position
	
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player_being_hit.animation_finished.connect(_on_animation_player_being_hit_animation_finished)
	hurt_box.damaged.connect(_on_hurt_box_damaged)
	health.health_empty.connect(_on_health_empty)
	attack_box.parried.connect(_on_attack_parried)
	LevelsVars.awake.connect(func(): is_enabled = false)
	LevelsVars.sleeping.connect(func(): is_enabled = true)
