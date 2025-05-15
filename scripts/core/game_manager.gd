extends Node
class_name GameManager

var player: Player;
var world_hub: WorldStreamer;
var MainCamera: CameraRigFollowPlayer;
var game_controller: GameController;
var companion: Companion;
var player_nav_region : NavigationRegion3D;
var companion_nav_region : NavigationRegion3D;
var view_portrait : SubViewport

func set_player(playerNode: Player):
	player = playerNode
	
func get_player() -> Player:
	return player
	
func set_companion(companionNode: Companion):
	companion = companionNode
	
func get_companion() -> Companion:
	return companion
	
func set_main_camera(CameraRigFollowPlayerNode: CameraRigFollowPlayer):
	MainCamera = CameraRigFollowPlayerNode

func get_main_camera() -> CameraRigFollowPlayer:
	return MainCamera
	
func set_player_nav_region(player_nav_regionNode: NavigationRegion3D):
	player_nav_region = player_nav_regionNode
	
func get_player_nav_region() -> NavigationRegion3D:
	return player_nav_region
	
func set_companion_nav_region(companion_nav_regionNode: NavigationRegion3D):
	companion_nav_region = companion_nav_regionNode
	
func get_companion_nav_region() -> NavigationRegion3D:
	return companion_nav_region
	
func set_view_portrait(view_portraitNode: SubViewport):
	view_portrait = view_portraitNode

func get_view_portrait():
	return view_portrait
