extends CharacterBody3D
class_name Player

# === RÉFÉRENCES ===
@onready var camera_positions: Array[Marker3D] = get_camera_positions()
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var charecter_visuals: Node3D = %Visuals
@onready var path_visualizer: Line3D = Line3D.new()
@onready var audio_stream_platform_sound: AudioStreamPlayer = %AudioStreamPlatformSound
@onready var player_position: Marker3D = %PlayerPosition
@onready var actionable_finder: Area3D = %ActionableFinder
@onready var actionable_ui: Control = %actionableUI
@onready var ui: CanvasLayer = %ui
@onready var inventory_ui_handler: InventoryHandler = %InventoryUI
@onready var _camera := game_manager.get_main_camera()
@onready var root : Node3D = $/root/Root

# === PARAMÈTRES ===
@export var Player_data = preload("res://resources/game/Player.tres")

# === VARIABLES"res://resources/game/Player.tres"
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var move_marker_prefab : PackedScene = preload('res://scenes/core/move_marker.tscn')
var camera_position: Marker3D
var current_velocity := Vector3.ZERO
var target_velocity := Vector3.ZERO
var actionable_ui_visible: bool = false
var last_ui_visible: bool = false

# === INITIALISATION ===
func _ready():
	initialize()
	setup_path_visualizer()
	setup_navigation()
	setup_animation()

func initialize():
	game_manager.set_player(self)
	set_camera_position_by_name("Top")

func setup_path_visualizer():
	if Player_data.show_path:
		add_child(path_visualizer)
		path_visualizer.set_as_top_level(true)

func setup_navigation():
	navigation_agent.avoidance_enabled = true

func setup_animation():
	animation_player.set_blend_time("Idle", "Run", 0.2)
	animation_player.set_blend_time("Run", "Idle", 0.2)
	
# === UI EVENT ===
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		action_actinable_area()

	if Input.is_action_just_released('move_click'):
		var query = PhysicsRayQueryParameters3D.create(
			_camera.project_ray_origin(event.position),
			_camera.project_ray_origin(event.position) + _camera.project_ray_normal(event.position) * 1000.0
		)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		var player_nav_region = game_manager.player_nav_region
		
		if result.has("position"):
			var p = move_marker_prefab.instantiate()
			root.add_child(p)
			p.global_position = result['position']
			p.global_position.y = p.global_position.y + 0.01
			var nav_point = NavigationServer3D.map_get_closest_point(
				player_nav_region.get_navigation_map(),
				result.position
			)
			if navigation_agent:
				navigation_agent.set_target_position(nav_point)
			else:
				push_error("Erreur : NavigationAgent3D du joueur non trouvé")

func action_actinable_area() -> void:
	var actionables = actionable_finder.get_overlapping_areas()
	if actionables.size() > 0:
		ui.visible = false
		actionables[0].action()
		return

# === PHYSICS ===
func _physics_process(delta: float):
	apply_gravity(delta)
	handle_movement(delta)
	update_animation()
	move_and_slide()
	
func _process(delta: float) -> void:
	var actionables = actionable_finder.get_overlapping_areas()
	actionable_ui_visible = actionables.size() > 0
	
	if actionable_ui_visible != last_ui_visible:
		actionable_ui.open_ui(actionable_ui_visible)
		last_ui_visible = actionable_ui_visible
		actionable_ui.callable = Callable(self, "action_actinable_area")
	
	follow_actionable_area(delta)
	
	music_controller.set_audio_position(global_position)
	
func  follow_actionable_area(delta: float) -> void:
	var position_2d = game_manager.MainCamera.unproject_position(global_transform.origin)
	var lerp_speed = 1.7
	actionable_ui.position = actionable_ui.position.lerp(position_2d, lerp_speed * delta)
	
# === GRAVITÉ ===
func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta * 2.0
	else:
		velocity.y = -0.01

# === MOUVEMENT NORMAL FLUID ===
func handle_movement(delta):
	if navigation_agent.is_navigation_finished():
		target_velocity = Vector3.ZERO
		current_velocity = current_velocity.move_toward(target_velocity, delta * Player_data.deceleration)
	else:
		var current_pos = global_position
		var next_pos = navigation_agent.get_next_path_position()
		var direction = (next_pos - current_pos).normalized()

		#var path = navigation_agent.get_current_navigation_path()
		#if path.size() > 1:
			#var lookahead_point = path[min(1, path.size() - 1)]
			#var future_dir = (lookahead_point - current_pos).normalized()
			#direction = direction.lerp(future_dir, 0.4).normalized()

		target_velocity = direction * Player_data.character_speed
		current_velocity = current_velocity.lerp(target_velocity, delta * Player_data.acceleration)

		if direction.length() > 0.1:
			var target_angle = atan2(direction.x, direction.z)
			charecter_visuals.rotation.y = lerp_angle(
				charecter_visuals.rotation.y, 
				target_angle, 
				delta * Player_data.rotation_speed
			)

		if Player_data.show_path:
			update_path_visualization(navigation_agent.get_target_position())

	move_character()

func move_character():
	velocity.x = current_velocity.x
	velocity.z = current_velocity.z
	Player_data.set_position(self.position)

# === ANIMATION ===
func update_animation():
	var speed = current_velocity.length()
	var is_moving = speed > 0.1

	if is_moving:
		animation_player.play("Run")
		animation_player.speed_scale = clamp(speed / Player_data.character_speed, 0.7, 1)
	else:
		animation_player.play("Idle")

# === NAVIGATION ===
func set_target_position(target_position: Vector3):
	navigation_agent.set_target_position(target_position)

# === AFFICHAGE DU CHEMIN ===
func update_path_visualization(target_position: Vector3):
	var path = NavigationServer3D.map_get_path(
		get_world_3d().navigation_map,
		global_position,
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

func foot_sptep_play() -> void:
	audio_stream_platform_sound.play()
