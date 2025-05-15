extends Node

@export var sound_tracks: Array[AudioStream] = [] # Liste des musiques (AudioStream)
@export var sound_tracks_players: Array[AudioStreamPlayer3D] = [] # Liste des AudioStreamPlayer3D (les "haut-parleurs")

# Paramètres pour la transition
@export var transition_duration: float = 2.0
@export var volume_range: Vector2 = Vector2(-20.0, 0.0) # dB min/max

# Suivi de la piste actuelle
var current_track: AudioStream
var previous_track: AudioStream

func _ready():
	for player in sound_tracks_players:
		if player:
			player.volume_db = volume_range.x
			if not player.is_connected("finished", Callable(self, "_on_music_finished")):
				player.connect("finished", Callable(self, "_on_music_finished").bind(player))
	
	if sound_tracks.size() > 0:
		play_random_music()

func play_music(new_track: AudioStream) -> void:
	if new_track == current_track or !new_track:
		return
	
	previous_track = current_track
	current_track = new_track
	
	for sound_player in sound_tracks_players:
		if not sound_player:
			continue
		if sound_player.playing:
			var tween = create_tween()
			tween.tween_property(sound_player, "volume_db", volume_range.x, transition_duration)
			tween.tween_callback(func():
				sound_player.stop()
				sound_player.stream = new_track
				sound_player.volume_db = volume_range.x
				sound_player.play()
				var tween_up = create_tween()
				tween_up.tween_property(sound_player, "volume_db", volume_range.y, transition_duration)
			)
		else:
			sound_player.stream = new_track
			sound_player.volume_db = volume_range.x
			sound_player.play()
			var tween = create_tween()
			tween.tween_property(sound_player, "volume_db", volume_range.y, transition_duration)

func play_random_music():
	if sound_tracks.size() == 0:
		return
	
	var available_tracks = sound_tracks.duplicate()
	if current_track and current_track in available_tracks:
		available_tracks.erase(current_track)
	
	if available_tracks.size() == 0:
		return
	
	var random_track = available_tracks[randi() % available_tracks.size()]
	play_music(random_track)

func _on_music_finished(_player = null) -> void:
	var all_finished = true
	for sound_player in sound_tracks_players:
		if sound_player and sound_player.playing:
			all_finished = false
			break
	
	if all_finished:
		play_random_music()
