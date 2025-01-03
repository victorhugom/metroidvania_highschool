class_name MoneyDropper extends Node2D

const MONEY = preload("res://props/money/money.tscn")

@export var quantity: int = 1

func drop():
	for i in range(0, quantity):
		var money = MONEY.instantiate()
		money.global_position = global_position + Vector2(randi_range(0, 20), randi_range(0, 20))
		
		var first_node = get_tree().current_scene.get_child(0)
		(first_node as Node2D).add_sibling.call_deferred(money)
