extends Node

signal sleeping()
signal awake()

@export var SLEEPING:= false

func sleep():
	SLEEPING = true
	sleeping.emit()
	
func wakeup():
	SLEEPING = false
	awake.emit()
