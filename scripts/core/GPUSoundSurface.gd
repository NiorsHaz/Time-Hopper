extends Area3D

@onready var _player = game_manager.get_player()

@export var surface_sound: AudioStream:
	set(new_value):
		surface_sound = new_value

@export var default_sound: AudioStream:
	set(new_value):
		default_sound = new_value

var _is_player_inside: bool = false

func _ready():
	if is_inside_tree():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body == _player:
		_is_player_inside = true
		if _player and _player.audio_stream_platform_sound:
			_player.audio_stream_platform_sound.set_stream(surface_sound)

func _on_body_exited(body: Node3D) -> void:
	if body == _player:
		_is_player_inside = false
		if _player and _player.audio_stream_platform_sound and default_sound:
			_player.audio_stream_platform_sound.set_stream(default_sound)
