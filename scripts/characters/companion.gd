extends CharacterBody3D
class_name Companion

# === RÉFÉRENCES ===
@onready var camera_positions: Array[Marker3D] = get_camera_positions()
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var charecter_visuals: Node3D = %Visuals
@onready var path_visualizer: Line3D = Line3D.new()
@onready var audio_stream_platform_sound: AudioStreamPlayer = %AudioStreamPlatformSound
@onready var companion_position: Marker3D = %Companion_position
@onready var view_portrait: SubViewport = %ViewPortrait

# === PARAMÈTRES ===
@export var Companion_data = preload("res://resources/game/Companion.tres")

# === VARIABLES ===
var camera_position: Marker3D
var current_velocity := Vector3.ZERO
var target_velocity := Vector3.ZERO
var float_offset: float = 0.0
var float_y: float = 0.0
var desired_height: float = 0.0
var current_amplitude: float = 0.0
@onready var _player := game_manager.get_player()

# === INITIALISATION ===
func _ready():
	initialize()
	setup_path_visualizer()
	setup_navigation()
	setup_animation()
	
func initialize():
	set_camera_position_by_name("Left")
	game_manager.set_companion(self)
	
func setup_path_visualizer():
	if Companion_data.show_path:
		add_child(path_visualizer)
		path_visualizer.set_as_top_level(true)

func setup_navigation():
	navigation_agent.avoidance_enabled = true
	
func setup_animation():
	animation_player.set_blend_time("Idle", "Run", 0.2)
	animation_player.set_blend_time("Run", "Idle", 0.2)
	
# === PHYSICS ===
func _physics_process(delta: float):
	handle_movement(delta)
	update_animation()
	move_and_slide()
	
# === NAVIGATION ===
#func _process(delta: float) -> void:
	#var companion_nav_region = game_manager.get_companion_nav_region()
	#if companion_nav_region:
		#navigation_agent.set_navigation_map(companion_nav_region.get_navigation_map())
	
# === MOUVEMENT FLOTTANT ===
func handle_movement(delta):

	# Mettre à jour l'oscillation pour l'effet de flottement
	float_offset += delta * Companion_data.float_speed
	
	# Augmenter progressivement l'amplitude jusqu'à Companion_data.float_amplitude_max
	current_amplitude += Companion_data.amplitude_increase_rate * delta
	current_amplitude = clamp(current_amplitude, Companion_data.float_amplitude_min, Companion_data.float_amplitude_max)
	
	var oscillation = sin(float_offset)
	var range_value = Companion_data.float_amplitude_max - Companion_data.float_amplitude_min
	var offset = (Companion_data.float_amplitude_max + Companion_data.float_amplitude_min) / 2.0
	float_y = oscillation * (range_value / 2.0) + offset
	
	desired_height = navigation_agent.get_next_path_position().y
	global_position.y = desired_height + float_y
	
	set_target_position()
	
	if navigation_agent.is_navigation_finished():
		target_velocity = Vector3.ZERO
		current_velocity = current_velocity.move_toward(target_velocity, delta * Companion_data.deceleration)
	else:
		var current_pos = global_position
		var next_pos = navigation_agent.get_next_path_position()
		var direction = (next_pos - current_pos).normalized()

		var path = navigation_agent.get_current_navigation_path()
		if path.size() > 1:
			var lookahead_point = path[min(1, path.size() - 1)]
			var future_dir = (lookahead_point - current_pos).normalized()
			direction = direction.lerp(future_dir, 0.4).normalized()

		target_velocity = direction * Companion_data.character_speed
		current_velocity = current_velocity.lerp(target_velocity, delta * Companion_data.acceleration)
		
		# Rotation fluide vers la direction du mouvement
		if direction.length() > 0.1:
			var target_angle = atan2(direction.x, direction.z)
			charecter_visuals.rotation.y = lerp_angle(
				charecter_visuals.rotation.y, 
				target_angle, 
				delta * Companion_data.rotation_speed
			)

		if Companion_data.show_path:
			update_path_visualization(navigation_agent.get_target_position())

	move_character()
		
func move_character():
	velocity = current_velocity	
	
# === ANIMATION ===
func update_animation():
	var speed = current_velocity.length()
	var is_moving = speed > 0.1
	
	if is_moving:
		animation_player.play("Run")
		animation_player.speed_scale = clamp(speed / Companion_data.character_speed, 0.7, 1)
	else:
		animation_player.play("Idle")

# === NAVIGATION ===
func set_target_position() -> void:
	if not _player:
		return
	# Attendre un frame pour s'assurer que tout est prêt
	await get_tree().physics_frame
	
	# Calculer la position cible : position du joueur + décalage
	var player_pos = _player.global_position
	var target_pos = player_pos + Companion_data.companion_distance_to_player
	navigation_agent.set_target_position(target_pos)

# === AFFICHAGE DU CHEMIN ===
func update_path_visualization(target_position: Vector3):
	var path = NavigationServer3D.map_get_path(
		get_world_3d().navigation_map,
		companion_position.global_position,
		target_position,
		true
	)
	path_visualizer.clear()
	path_visualizer.add_points(path)

# === CAMERA ===
func get_camera_positions() -> Array[Marker3D]:
	var positions: Array[Marker3D] = []
	for child in %CameraPoints.get_children():
		if child is Marker3D:
			positions.append(child)
	return positions

func set_camera_position_by_index(index: int):
	if index >= 0 and index < camera_positions.size():
		camera_position = camera_positions[index]

func set_camera_position_by_name(point_name: String):
	for point in camera_positions:
		if point.name == point_name:
			camera_position = point
			return
	push_error("Point caméra '%s' introuvable" % point_name)
