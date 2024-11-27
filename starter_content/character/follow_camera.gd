class_name FollowCamera extends Camera2D

## (optional) The biggest Tile Map Layer to set the Camera Left and Bottom limit, to use this your layer needs to starts on 0,0
@export var ground_map_tile: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_camera_limit():
	if ground_map_tile != null:
		var map_limits = ground_map_tile.get_used_rect()
		var map_cellsize = 32
		var worldMapInPixels = map_limits.size * map_cellsize
		limit_right = worldMapInPixels.x
		limit_bottom = worldMapInPixels.y
