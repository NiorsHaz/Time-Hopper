extends Node3D

const mesh_factory = preload("res://scripts/core/mesh_factory.gd")
const grass_factory = preload("res://scripts/core/grass_factory.gd")

@onready var _camera := game_manager.get_main_camera()
@onready var _player := game_manager.get_player()

enum LODReference { CAMERA, PLAYER }

@export var lod_reference: LODReference = LODReference.CAMERA:
	set(new_value):
		lod_reference = new_value
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()
			
@export var max_distance: float = 20.0:
	set(new_value):
		max_distance = new_value

@export var cast_shadow: bool:
	set(new_value):
		cast_shadow = new_value
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var material: Material:
	set(new_value):
		material = new_value
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var blade_width: Vector2 = Vector2(0.02, 0.04):
	set(new_value):
		blade_width = new_value
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var blade_height: Vector2 = Vector2(0.2, 0.4):
	set(new_value):
		blade_height = new_value
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var sway_yaw: Vector2 = Vector2(0.0, 10.0):
	set(new_value):
		sway_yaw = new_value
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var sway_pitch: Vector2 = Vector2(0.0, 20.0):
	set(new_value):
		sway_pitch = new_value
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var mesh: Mesh = null:
	set(new_value):
		mesh = new_value

@export var density: float = 2.0:
	set(new_value):
		density = new_value
		if density < 1.0:
			density = 1.0
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var max_instances_per_chunk: int = 10000:
	set(new_value):
		max_instances_per_chunk = new_value
		if max_instances_per_chunk < 1000:
			max_instances_per_chunk = 1000
		if is_inside_tree() and not Engine.is_editor_hint():
			_trigger_rebuild()

@export var grid_size: int = 10: # Nombre de chunks sur chaque axe (par exemple, 10x10 = 100 chunks)
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

@export var chunk_dimensions: float = 2.0: # Taille de chaque chunk (carré)
	set(new_value):
		chunk_dimensions = new_value
		if chunk_dimensions < 0.1:
			chunk_dimensions = 0.1
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
		#_trigger_rebuild()

func _trigger_rebuild():
	if is_inside_tree():
		call_deferred("rebuild")
	else:
		print("GPUGrass: _trigger_rebuild appelé mais nœud hors de l'arborescence pour ", name)

func rebuild():
	if not is_inside_tree():
		return
	
	if not _needs_rebuild:
		return
	_needs_rebuild = false
	
	# Supprimer tous les enfants (load_zone n'est pas un enfant, donc pas affecté)
	for child in get_children():
		child.queue_free()
	
	if not mesh:
		print("GPUGrass: Mesh non défini pour ", name, ", génération uniforme")
	
	# Générer une grille de chunks (grid_size x grid_size)
	var chunks = {}
	var half_grid = grid_size / 2.0
	for x in range(-half_grid, half_grid):
		for z in range(-half_grid, half_grid):
			var chunk_key = Vector2(x, z)
			# Calculer la position du chunk, centrée dans la zone
			var chunk_pos = Vector3(
				x * (chunk_dimensions + chunk_spacing),
				0,
				z * (chunk_dimensions + chunk_spacing)
			)
			# Ajouter le décalage de la zone
			chunk_pos += Vector3(_zone_pos.x * 100, 0, _zone_pos.y * 100)
			
			# Générer les brins d'herbe pour ce chunk
			var spawns = grass_factory.generate(
				mesh,
				density,
				blade_width,
				blade_height,
				sway_pitch,
				sway_yaw,
				chunk_pos,
				chunk_dimensions
			)
			
			if spawns.is_empty():
				print("Avertissement : spawns vide pour chunk à ", chunk_pos)
				continue
			
			# Limiter le nombre de brins par chunk
			if spawns.size() > max_instances_per_chunk:
				spawns.resize(max_instances_per_chunk)
			
			chunks[chunk_key] = spawns
	
	# Créer les MultiMeshInstance3D pour chaque chunk
	for chunk_key in chunks:
		var chunk_spawns = chunks[chunk_key]
		var mm_instance = MultiMeshInstance3D.new()
		mm_instance.multimesh = MultiMesh.new()
		
		if !cast_shadow:
			mm_instance.cast_shadow = 0
		var mm = mm_instance.multimesh
		mm.mesh = mesh_factory.simple_grass(0)
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_custom_data = true
		mm.use_colors = false
		mm.instance_count = chunk_spawns.size()
		
		# Calculer la position du MultiMeshInstance3D
		var chunk_pos = Vector3(
			chunk_key.x * (chunk_dimensions + chunk_spacing),
			0,
			chunk_key.y * (chunk_dimensions + chunk_spacing)
		)
		chunk_pos += Vector3(_zone_pos.x * 100, 0, _zone_pos.y * 100)
		
		# Convertir les transformations absolues en transformations relatives
		for i in mm.instance_count:
			var spawn = chunk_spawns[i]
			var _transform: Transform3D = spawn[0]
			# Extraire la position absolue et la rotation
			var absolute_pos = _transform.origin
			var _basis = _transform.basis
			# Calculer la position relative par rapport à chunk_pos
			var relative_pos = absolute_pos - chunk_pos
			# Créer une nouvelle transformation relative
			var relative_transform = Transform3D(_basis, relative_pos)
			# Appliquer la transformation relative
			mm.set_instance_transform(i, relative_transform)
			mm.set_instance_custom_data(i, spawn[1])
		
		if material:
			mm_instance.material_override = material
		else:
			print("GPUGrass: Aucun matériau défini pour ", name, ", chunk ", chunk_key)
		
		add_child(mm_instance)
		if Engine.is_editor_hint() and get_tree().edited_scene_root != null:
			mm_instance.owner = get_tree().edited_scene_root
		mm_instance.name = "Chunk_" + str(chunk_key)
		
		mm_instance.global_position = chunk_pos
	
	print("GPUGrass: Fin de rebuild pour ", name, ", chunks créés : ", chunks.size())

func _process(delta: float) -> void:
	update_timer += delta
	if update_timer < update_interval:
		return
	update_timer = 0.0
	
	var reference_pos: Vector3
	if lod_reference == LODReference.CAMERA:
		if not _camera:
			return
		reference_pos = _camera.global_position
	else:
		if not _player:
			return
		reference_pos = _player.global_position
	
	for child in get_children():
		var mm_instance: MultiMeshInstance3D = child
		var chunk_pos = mm_instance.global_position
		var distance = reference_pos.distance_to(chunk_pos)
		
		if distance > max_distance:
			mm_instance.visible = false
			continue
		
		mm_instance.visible = true
