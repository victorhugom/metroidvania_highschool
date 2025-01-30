extends Area2D

@export var zoom: Vector2 = Vector2(1.5, 1.5)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_body_entered(body: CharacterBody2D):
	var player = body as Player
	player.follow_camera.update_zoom(zoom)
