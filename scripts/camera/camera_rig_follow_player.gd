extends Camera3D
class_name CameraRigFollowPlayer

@onready var base_camera: CameraRigFollowPlayer = $"."

@export var smooth_speed: float = 5.0
@export var folowRef : Node3D

func _ready():
	game_manager.set_main_camera(self)

func _process(delta):
	update_camera_position(delta)

func update_camera_position(delta: float):
	if folowRef and folowRef.camera_position:
		var target_transform = folowRef.camera_position.global_transform

		# Interpolation de la position
		var new_position = base_camera.global_transform.origin.lerp(
			target_transform.origin,
			clamp(smooth_speed * delta, 0.0, 1.0)
		)

		# Interpolation de la rotation avec slerp
		var new_basis = base_camera.global_transform.basis.slerp(
			target_transform.basis,
			clamp(smooth_speed * delta, 0.0, 1.0)
		)

		# Appliquer la nouvelle transformation
		base_camera.global_transform = Transform3D(new_basis, new_position)
		
func set_folow_ref(ref: Node3D) -> void:
	folowRef = ref
