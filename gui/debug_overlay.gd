class_name DebugOverlay extends CanvasLayer

@onready var rich_text_label: RichTextLabel = $RichTextLabel

@export var ON:= false

func show_message(message: String):
	rich_text_label.text = message
	
func clear():
	rich_text_label.text = ""
