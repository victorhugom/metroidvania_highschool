extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelsVars.sleeping.connect(_on_sleeping)
	LevelsVars.awake.connect(_on_awake)
	
	if LevelsVars.SLEEPING:
		_on_sleeping()
	else:
		_on_awake()

func _process(delta: float) -> void:
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
	
	var awake_only_nodes = get_tree().get_nodes_in_group("awake_only_node") 
	var sleep_only_nodes = get_tree().get_nodes_in_group("sleep_only_node") 
	
	for node in awake_only_nodes:
		_enable_node(node)
	
	for node in sleep_only_nodes:
		_disable_node(node)


func _disable_node(node):
	if node is TileMapLayer:
		(node as TileMapLayer).enabled = false
	if node is Sprite2D:
		pass
	if node is Area2D:
		(node as Area2D).monitorable = false
		(node as Area2D).monitoring = false
		
	node.visible = false	
		
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate", Color(Color.WHITE, 0), .3).set_trans(Tween.TRANS_SINE)

func _enable_node(node):
	if node is TileMapLayer:
		(node as TileMapLayer).enabled = true
	if node is Sprite2D:
		pass
	if node is Area2D:
		(node as Area2D).monitorable = true
		(node as Area2D).monitoring = true
		
	node.visible = true
		
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate", Color.WHITE, .3).set_trans(Tween.TRANS_SINE)
