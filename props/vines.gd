class_name Vine extends TileMapLayer

func destroy():
	var tween = get_tree().create_tween();
	tween.tween_property(self, "material:shader_parameter/intensity", 1, .3)	
	tween.tween_callback(queue_free).set_delay(.8)
