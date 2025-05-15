extends GPUParticles3D
@onready var _player = game_manager.get_player()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == _player:
		if _player:
			self.visible = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == _player:
		if _player:
			self.visible = false

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(_player.global_position, 1.0 - exp(-10.0 * delta))
