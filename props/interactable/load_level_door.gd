class_name Door extends Node2D

@onready var player: Player = %Player
@onready var player_position: Marker2D = $PlayerPosition

@export_file("*.tscn") var target_scene_path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if LevelsVars.previous_level_path == target_scene_path:
		player.global_position = player_position.global_position

		
func _on_interactable_switch_interact(_body: Node2D) -> void:
	LevelsVars.previous_level_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(target_scene_path)
	
