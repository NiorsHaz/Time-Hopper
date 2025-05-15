extends CanvasLayer

func _on_jouer_pressed() -> void:
	game_manager.game_controller.change_gui_scene("res://scenes/ui/animation_screen.tscn")
