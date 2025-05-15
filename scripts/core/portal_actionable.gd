extends Area3D
class_name PortalActionnable

@onready var animation_player: AnimationPlayer = %AnimationPlayer
var is_open: bool = false
var is_return: bool

var next_world : Vector2i
var Sociability_requis : int
var qi_requis : int

func action() -> void:
	if is_return:
		state_dialogue.reset()

	var Sociability: Array[Essence] = game_manager.player.Player_data.filtre_essences('SOCIABILITY', true)
	var Qi: Array[Essence] = game_manager.player.Player_data.filtre_essences('QI', true)
	if not animation_player.is_playing():
		animation_player.play("close" if is_open else "open")
		is_open = !is_open
	if Essence.get_total_value(Sociability) >= Sociability_requis and Essence.get_total_value(Qi) >= qi_requis:
		if state_dialogue.return_number < 3:
			game_manager.world_hub._change_zone(next_world)
	game_manager.get_player().ui.visible = true
