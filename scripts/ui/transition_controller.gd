class_name TransitionController
extends PanelContainer

@export var background : ColorRect
@export var animation_player : AnimationPlayer

func transition(animation: String, seconds: float) -> void:
	animation_player.play(animation, -1.0, 1 / seconds)
