@tool
extends GPUParticles3D

# Enum pour choisir le type d'effet
enum EffectType { DUST, FIREFLY }

# Paramètres exposés dans l'inspecteur
@export var effect_type: EffectType = EffectType.DUST : set = _set_effect_type
@export var particle_amount: int = 100 : set = _set_particle_amount
@export var emission_box_extents: Vector3 = Vector3(5, 2, 5) : set = _set_emission_box_extents
@export var particle_lifetime: float = 5.0 : set = _set_particle_lifetime
@export var movement_speed_min: float = 0.2 : set = _set_movement_speed_min
@export var movement_speed_max: float = 0.5 : set = _set_movement_speed_max
@export var particle_scale: float = 0.05 : set = _set_particle_scale
@export var base_color: Color = Color(0.8, 0.8, 0.8, 0.1) : set = _set_base_color
@export var emission_energy: float = 0.0 : set = _set_emission_energy
@export var twinkle_enabled: bool = false : set = _set_twinkle_enabled

# Variables internes
var _process_material: ParticleProcessMaterial
var _draw_material: StandardMaterial3D
var _quad_mesh: QuadMesh

func _ready():
	_setup_particle_system()

func _process(_delta):
	if Engine.is_editor_hint():
		# Mise à jour en temps réel dans l'éditeur
		_setup_particle_system()

# Configure le système de particules
func _setup_particle_system():
	# Initialiser le ProcessMaterial
	if not _process_material:
		_process_material = ParticleProcessMaterial.new()
	if not process_material or process_material != _process_material:
		process_material = _process_material
	
	# Initialiser le QuadMesh et le StandardMaterial3D
	if not _quad_mesh:
		_quad_mesh = QuadMesh.new()
		_quad_mesh.size = Vector2(particle_scale, particle_scale)
	
	if not draw_pass_1 or not (draw_pass_1 is QuadMesh):
		draw_pass_1 = _quad_mesh
	
	if not _draw_material:
		_draw_material = StandardMaterial3D.new()
		_quad_mesh.material = _draw_material
	
	# Vérifier que process_material est valide avant de continuer
	if not _process_material:
		push_error("Failed to initialize process_material")
		return
	
	# Paramètres généraux
	amount = particle_amount
	lifetime = particle_lifetime
	emitting = true
	
	# Configuration du ProcessMaterial
	_process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	_process_material.emission_box_extents = emission_box_extents
	
	# Mouvement
	_process_material.initial_velocity_min = movement_speed_min
	_process_material.initial_velocity_max = movement_speed_max
	_process_material.damping_min = 0.5
	_process_material.damping_max = 1.0
	
	# Gravité et comportement selon le type
	if effect_type == EffectType.DUST:
		_process_material.gravity = Vector3(0, 0.1, 0)
		_process_material.orbit_velocity_min = 0.0
		_process_material.orbit_velocity_max = 0.0
	else: # FIREFLY
		_process_material.gravity = Vector3(0, 0, 0)
		_process_material.orbit_velocity_min = -0.2
		_process_material.orbit_velocity_max = 0.2
	
	# Scintillement pour les lucioles
	if twinkle_enabled and effect_type == EffectType.FIREFLY:
		var color_curve = Curve.new()
		color_curve.add_point(Vector2(0.0, 0.2))
		color_curve.add_point(Vector2(0.5, 1.0))
		color_curve.add_point(Vector2(1.0, 0.2))
		_process_material.color = base_color
		_process_material.color_curve = color_curve
	else:
		_process_material.color = base_color
		# Ne pas assigner null à color_curve, car c'est déjà la valeur par défaut
	
	# Configuration du Draw Material
	_draw_material.billboard_mode = StandardMaterial3D.BILLBOARD_ENABLED
	_draw_material.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	_draw_material.albedo_color = base_color
	_draw_material.emission_enabled = emission_energy > 0.0
	_draw_material.emission = base_color
	_draw_material.emission_energy_multiplier = emission_energy
	
	# Ajuster la taille du QuadMesh
	_quad_mesh.size = Vector2(particle_scale, particle_scale)

# Setters pour mise à jour dynamique
func _set_effect_type(value: int):
	effect_type = value
	_setup_particle_system()

func _set_particle_amount(value: int):
	particle_amount = clamp(value, 10, 1000)
	_setup_particle_system()

func _set_emission_box_extents(value: Vector3):
	emission_box_extents = value
	_setup_particle_system()

func _set_particle_lifetime(value: float):
	particle_lifetime = clamp(value, 1.0, 20.0)
	_setup_particle_system()

func _set_movement_speed_min(value: float):
	movement_speed_min = clamp(value, 0.0, 2.0)
	_setup_particle_system()

func _set_movement_speed_max(value: float):
	movement_speed_max = clamp(value, movement_speed_min, 2.0)
	_setup_particle_system()

func _set_particle_scale(value: float):
	particle_scale = clamp(value, 0.01, 0.5)
	_setup_particle_system()

func _set_base_color(value: Color):
	base_color = value
	_setup_particle_system()

func _set_emission_energy(value: float):
	emission_energy = clamp(value, 0.0, 5.0)
	_setup_particle_system()

func _set_twinkle_enabled(value: bool):
	twinkle_enabled = value
	_setup_particle_system()
