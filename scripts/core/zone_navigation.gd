extends Node3D
class_name Zone

# === RÉFÉRENCES ===
@onready var _camera := game_manager.get_main_camera()
@onready var _player := game_manager.get_player()
@onready var _companion := game_manager.get_companion()
@onready var player_nav_agent: NavigationAgent3D = _player.navigation_agent
@onready var player_nav_region: NavigationRegion3D = %PlayerNavRegion
@onready var companion_nav_agent: NavigationAgent3D = _companion.navigation_agent
@onready var companion_nav_region: NavigationRegion3D = %CompanionNavRegion

func _ready() -> void:
	game_manager.player_nav_region = player_nav_region
	game_manager.companion_nav_region = companion_nav_region
	initialize_navigation()
	
func initialize_navigation() -> void:
	if player_nav_agent and player_nav_region and companion_nav_agent and companion_nav_region:
		player_nav_agent.set_navigation_map(player_nav_region.get_navigation_map())
		companion_nav_agent.set_navigation_map(companion_nav_region.get_navigation_map())
	else:
		push_error("Erreur : NavigationAgent3D non trouvé")
