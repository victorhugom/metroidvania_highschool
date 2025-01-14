extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelsVars.sleeping.connect(_on_sleeping)
	LevelsVars.awake.connect(_on_awake)
	
	if LevelsVars.SLEEPING:
		_on_sleeping()
	else:
		_on_awake()

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_L):
		LevelsVars.sleep()
	if Input.is_key_pressed(KEY_K):
		LevelsVars.wakeup()

func _on_sleeping():
	var awake_only_nodes = get_tree().get_nodes_in_group("awake_only_node") 
	var sleep_only_nodes = get_tree().get_nodes_in_group("sleep_only_node") 

	for node in sleep_only_nodes:
		_enable_node(node)
	
	for node in awake_only_nodes:
		_disable_node(node)

func _on_awake():
	
	#disable/enable nodes
	var awake_only_nodes = get_tree().get_nodes_in_group("awake_only_node") 
	var sleep_only_nodes = get_tree().get_nodes_in_group("sleep_only_node") 
	
	for node in awake_only_nodes:
		_enable_node(node)
	
	for node in sleep_only_nodes:
		_disable_node(node)

func _disable_node(node):
	if node is TileMapLayer:
		(node as TileMapLayer).enabled = false
		node.visible = false
	if node is Sprite2D:
		node.visible = false
		pass
	if node is Area2D:
		(node as Area2D).monitorable = false
		(node as Area2D).monitoring = false
		node.visible = false
	if node is CollisionShape2D:
		(node as CollisionShape2D).disabled = true
		node.visible = false
	if node is Polygon2D:
		var tween = get_tree().create_tween();
		tween.tween_property(node, "material:shader_parameter/intensity", 1, .8)	

func _enable_node(node):
	if node is TileMapLayer:
		(node as TileMapLayer).enabled = true
		node.visible = true
	if node is Sprite2D:
		node.visible = true
		pass
	if node is Area2D:
		(node as Area2D).monitorable = true
		(node as Area2D).monitoring = true
		node.visible = true
	if node is CollisionShape2D:
		(node as CollisionShape2D).disabled = false
		node.visible = true
	if node is Polygon2D:
		var tween = get_tree().create_tween();
		tween.tween_property(node, "material:shader_parameter/intensity", 0.1, .8)	
