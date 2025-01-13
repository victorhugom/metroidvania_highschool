extends Node

signal sleeping()
signal awake()

@export var SLEEPING:= false
@export var previous_level_path = "res://levels/main.tscn"

func sleep():
	SLEEPING = true
	sleeping.emit()
	
func wakeup():
	SLEEPING = false
	awake.emit()
