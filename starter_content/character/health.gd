class_name Health extends Node2D

## Emitted when the health becomes 0 and every time try to decrease it after is 0
signal health_empty
signal health_full
signal health_changed(current_health: int)

## Max player health
@export_range(1, 999999) var max_health: int = 1

var current_health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health

func decrease_health(value: int = 1) -> bool:
	
	if current_health <= 0:
		health_empty.emit()
			
		print_rich("[color=red][b] Health: Try Descreased Health: No health to loose [/b][/color]")
		print_debug("")
		return false
		
	current_health -= value
	print_rich("[color=green][b] Health: Descreased Health by: [/b][/color]: %s current health: %s" %[value, current_health])
	health_changed.emit(current_health)
	
	if current_health <= 0:
		health_empty.emit()
		print_rich("[color=red][b] Health: Empty: No health to loose [/b][/color]")
		
	return true

func increase_health(value: int = 1) -> bool:
	
	if current_health >= max_health: 
		print_rich("[color=red][b] Health: Try increased Health: Max health [/b][/color]")
		health_full.emit()
		return false
	
	current_health += value
	health_changed.emit(current_health)
	print_rich("[color=green][b] Health: Increase Health by: [/b][/color]: %s current health: %s" %[value, current_health])
	
	if current_health == max_health:
		health_full.emit()
	
	return true
