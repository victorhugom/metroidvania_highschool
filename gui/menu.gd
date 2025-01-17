extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rich_text_label_time: RichTextLabel = $RichTextLabel_Time

var is_menu_open:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#animation_player.animation_finished.connect(_animation_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rich_text_label_time.text = get_current_time()

func get_current_time() -> String:
	var now = Time.get_time_dict_from_system()
	return "%d:%d:%d" % [now.hour, now.minute, now.second]
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_menu"):
		if is_menu_open:
			animation_player.play("hide_phone")
			is_menu_open = false
		else:
			animation_player.play("show_phone")
			is_menu_open = true
			
#func _animation_finished(anim_name):
	#if anim_name == "show_phone":
		#menu_container.visible = true
		#background.visible = true
