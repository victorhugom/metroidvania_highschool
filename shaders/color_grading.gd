extends Node2D

@export var night_resource: Resource
@export var day_resource: Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelsVars.sleeping.connect(_on_sleeping)
	LevelsVars.awake.connect(_on_awake)
	
	if LevelsVars.SLEEPING:
		_on_sleeping()
	else:
		_on_awake()

func _on_sleeping():
	material.set_shader_parameter("pal0", night_resource)

func _on_awake():
	material.set_shader_parameter("pal0", day_resource)
