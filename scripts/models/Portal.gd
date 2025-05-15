extends StaticBody3D
class_name Portal

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@export var next_world = Vector2i (0,0)
@export var Sociability_requis = 30
@export var qi_requis = 30
@export var is_return = false

@export var portal_actionnable: PortalActionnable

func _ready() -> void:
	animation_player.play("close")
	portal_actionnable.is_return = is_return
	portal_actionnable.next_world = next_world
	portal_actionnable.Sociability_requis = Sociability_requis
	portal_actionnable.qi_requis = qi_requis
	

func animation_finish():
	game_manager.get_player().ui.visible = true
