extends CanvasLayer

@onready var health_bar: Sprite2D = $HealthBar
@onready var energy_bar: Sprite2D = $EnergyBar
@onready var money_count: RichTextLabel = $CenterContainer/MoneyCount

@export var health: int = 10:
	get:
		return health
	set(value):
		health = value
		health_bar.frame = value
		
@export var energy: int = 3:
	get:
		return energy
	set(value):
		energy = value
		energy_bar.frame = int(energy/10)
		
@export var money: int = 3:
	get:
		return money
	set(value):
		money = value
		money_count.text = str(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
