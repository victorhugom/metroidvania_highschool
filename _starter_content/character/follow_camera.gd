class_name FollowCamera extends Camera2D

## (optional) The biggest Tile Map Layer to set the Camera Left and Bottom limit, to use this your layer needs to starts on 0,0
@export var ground_map_tile: TileMapLayer

# Variables for zoom
var zoom_speed = 0.5
var target_zoom = Vector2(1.5, 1.5)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame
func _process(delta):
	# Smoothly interpolate the zoom value
	zoom = lerp(zoom, target_zoom, zoom_speed * delta)
	
	if Input.is_key_pressed(KEY_EQUAL):
		update_zoom(Vector2(1.5, 1.5))
	if Input.is_key_pressed(KEY_MINUS):
		update_zoom(Vector2(2.5, 2.5))
		
func set_camera_limit():
	if ground_map_tile != null:
		var map_limits = ground_map_tile.get_used_rect()
		var map_cellsize = 32
		var worldMapInPixels = map_limits.size * map_cellsize
		limit_right = worldMapInPixels.x
		limit_bottom = worldMapInPixels.y
		
# Function to set the target zoom
func update_zoom(new_zoom: Vector2):
	target_zoom = new_zoom
