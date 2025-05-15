extends Node

# Array pour les pistes musicales
@export var music_tracks: Array[AudioStream] = []

# Paramètres pour la spatialisation et la dynamique
@export var max_distance: float = 20.0
@export var transition_duration: float = 2.0
@export var volume_range: Vector2 = Vector2(-20.0, 0.0) # dB min/max

# Références aux joueurs audio
var current_player: AudioStreamPlayer3D
var next_player: AudioStreamPlayer3D

# Suivi de la piste actuelle
var current_track: AudioStream

func _ready():
	# Initialiser les joueurs audio 3D
	current_player = AudioStreamPlayer3D.new()
	next_player = AudioStreamPlayer3D.new()
	
	# Configurer la spatialisation
	current_player.max_distance = max_distance
	next_player.max_distance = max_distance
	
	# Ajouter à la scène
	add_child(current_player)
	add_child(next_player)
	
	# Connecter les signaux pour boucler
	current_player.finished.connect(_on_music_finished)
	next_player.finished.connect(_on_music_finished)

# Jouer une piste avec transition fluide
func play_music(new_track: AudioStream):
	if new_track == current_track or !new_track:
		return
	
	# Préparer la transition
	var previous_player = current_player
	current_player = next_player
	next_player = previous_player
	
	# Configurer la nouvelle piste
	current_track = new_track
	current_player.stream = new_track
	current_player.volume_db = volume_range.x
	current_player.play()
	
	# Transition fluide
	var tween = create_tween()
	tween.tween_property(current_player, "volume_db", volume_range.y, transition_duration)
	tween.parallel().tween_property(next_player, "volume_db", volume_range.x, transition_duration)
	tween.tween_callback(next_player.stop)

# Jouer une piste aléatoire
func play_random_music():
	if music_tracks.size() > 0:
		var random_track = music_tracks[randi() % music_tracks.size()]
		play_music(random_track)

# Boucler la piste actuelle
func _on_music_finished():
	if current_track:
		current_player.play()

# Positionner le son dans l'espace
func set_audio_position(position: Vector3):
	current_player.global_position = position
	next_player.global_position = position

# Arrêter la musique
func stop_music():
	var tween = create_tween()
	tween.tween_property(current_player, "volume_db", volume_range.x, transition_duration)
	tween.parallel().tween_property(next_player, "volume_db", volume_range.x, transition_duration)
	tween.tween_callback(current_player.stop)
	tween.tween_callback(next_player.stop)
	current_track = null
