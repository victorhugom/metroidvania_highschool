extends CanvasModulate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelsVars.sleeping.connect(_on_sleeping)
	LevelsVars.awake.connect(_on_awake)
	
	if LevelsVars.SLEEPING:
		_on_sleeping()
	else:
		_on_awake()

func _on_sleeping():
	color = Color("754970")

func _on_awake():
	color = Color("d8b3d2")
