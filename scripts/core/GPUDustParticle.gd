extends Node3D

const DUST_PARTICLES_3D = preload("res://scenes/core/dust_particles_3d.tscn")

@export var grid_size: int = 2: # Nombre de chunks sur chaque axe (par exemple, 2x2 = 4 chunks)
	set(new_value):
		grid_size = new_value
		if grid_size < 1:
			grid_size = 1
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var chunk_spacing: float = 1.0: # Espacement entre les chunks
	set(new_value):
		chunk_spacing = new_value
		if chunk_spacing < 0.0:
			chunk_spacing = 0.0
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

var update_timer: float = 0.0
var update_interval: float = 0.1
var _needs_rebuild: bool = true
var _zone_pos: Vector2 = Vector2.ZERO

func _ready():
	if is_inside_tree():
		_zone_pos = Vector2(int(global_position.x / 100), int(global_position.z / 100))
		_needs_rebuild = true
		_trigger_rebuild()

func _trigger_rebuild():
	if is_inside_tree():
		call_deferred("rebuild")
	else:
		print("GPUDustParticle: _trigger_rebuild appelé mais nœud hors de l'arborescence pour ", name)

func rebuild():
	if not is_inside_tree():
		return
	
	if not _needs_rebuild:
		return
	_needs_rebuild = false
	
	# Supprimer tous les enfants existants
	for child in get_children():
		child.queue_free()
	
	# Générer une grille de chunks (grid_size x grid_size)
	var chunk_size = 1.0 # Taille de base d'un chunk
	var total_chunk_size = chunk_size + chunk_spacing # Taille totale d'un chunk (avec espacement)
	
	for x in range(grid_size):
		for z in range(grid_size):
			var chunk_key = Vector2(x, z)
			var chunk_pos = Vector3(
				(x - (grid_size - 1) / 2.0) * total_chunk_size,
				0,
				(z - (grid_size - 1) / 2.0) * total_chunk_size
			)

			chunk_pos += Vector3(_zone_pos.x * 100, 0, _zone_pos.y * 100)
			
			var dust_instance = DUST_PARTICLES_3D.instantiate()
			dust_instance.set_name("DustChunk_" + str(chunk_key))
			add_child(dust_instance)
			if Engine.is_editor_hint() and get_tree().edited_scene_root != null:
				dust_instance.owner = get_tree().edited_scene_root
			
			dust_instance.global_position = chunk_pos
	
	print("GPUDustParticle: Fin de rebuild pour ", name, ", chunks créés : ", grid_size * grid_size)
