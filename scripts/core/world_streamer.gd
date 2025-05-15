extends Node3D
class_name WorldStreamer

@export var world_3d: Node3D

const ZONE_SIZE: float = 100.0
const LOAD_distance: int = 1
const ZONE_PATH: String = "res://scenes/zones/zone_%d_%d.tscn"
const WORLD_HUB: String = "res://scenes/main/worlds/world_hub.tscn"
const DIRECTORY: String = "res://resources/game/World.tres"

var UI_MENU: CanvasLayer

@export var WorldHistory: WorldZone = preload("res://resources/game/World.tres")
@export var zone_id: Vector2i = Vector2i(0, 0)

var loaded_zones: Dictionary = {}

func _ready() -> void:
	UI_MENU = $Display
	game_manager.world_hub = self
	music_controller.play_random_music()
	if ResourceLoader.exists(DIRECTORY):
		var saved_history: WorldZone = ResourceLoader.load(DIRECTORY)
		WorldHistory.current_zone = saved_history.current_zone
	else:
		WorldHistory.current_zone = zone_id
		ResourceSaver.save(WorldHistory, DIRECTORY)
	
	_update_loaded_zones()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_escape") && UI_MENU.visible == false:
		if game_manager.get_player().ui.visible == true : game_manager.get_player().ui.visible = false
		UI_MENU.visible = true
	elif event.is_action_pressed("ui_escape") && UI_MENU.visible == true:
		if game_manager.get_player().ui.visible == false : game_manager.get_player().ui.visible = true
		UI_MENU.visible = false

func _change_zone(new_zone_id: Vector2i) -> void:
	WorldHistory.current_zone = new_zone_id
	ResourceSaver.save(WorldHistory, DIRECTORY)
	
	get_tree().change_scene_to_file(WORLD_HUB)

func _update_loaded_zones() -> void:
	var zones_to_load: Array[Vector2i] = [WorldHistory.current_zone]
	
	for id in zones_to_load:
		if id not in loaded_zones:
			_load_zone(id)
	
	var zones_to_unload: Array[Vector2i] = []
	for id in loaded_zones.keys():
		if id != WorldHistory.current_zone:
			zones_to_unload.append(id)
	for id in zones_to_unload:
		_unload_zone(id)

func _load_zone(id: Vector2i) -> void:
	var scene_path: String = ZONE_PATH % [id.x, id.y]
	if ResourceLoader.exists(scene_path):
		var scene = load(scene_path).instantiate()
		_fix_collision_priority(scene)
		
		world_3d.add_child(scene)
		scene.global_position = Vector3(0, 0, 0)
		
		loaded_zones[id] = scene
		print("Loaded zone: %s" % id)
	else:
		push_warning("Zone scene not found: %s" % scene_path)

func _unload_zone(id: Vector2i) -> void:
	if id in loaded_zones:
		var zone: Node = loaded_zones[id]
		zone.queue_free()
		loaded_zones.erase(id)
		print("Unloaded zone: %s" % id)

func _fix_collision_priority(node: Node) -> void:
	if node is CollisionObject3D:
		if node.collision_priority <= 0:
			print("Fixing collision_priority for %s in zone %s" % [node.name, WorldHistory.current_zone])
			node.collision_priority = 1.0
	for child in node.get_children():
		_fix_collision_priority(child)


func _on_button_pressed() -> void:
	if UI_MENU.visible == true:
		if game_manager.get_player().ui.visible == false : game_manager.get_player().ui.visible = true
		UI_MENU.visible = false

func _on_button_3_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main/main.tscn")


func _on_button_4_pressed() -> void:
	get_tree().quit()
