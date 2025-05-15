extends Button

var old_text: String

func _ready() -> void:
	old_text = text

func _on_mouse_entered() -> void:
	text = "[" + text + "]"


func _on_mouse_exited() -> void:
	text = old_text
