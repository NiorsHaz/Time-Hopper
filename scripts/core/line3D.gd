extends MeshInstance3D
class_name Line3D

@export var line_color: Color = Color.WHITE_SMOKE
@export var line_width: float = 0.1
@export var point_size: float = 0.3
@export var show_points: bool = true

var _immediate_mesh: ImmediateMesh
var _material: StandardMaterial3D

func _ready():
	setup_mesh()
	setup_material()

func setup_mesh():
	_immediate_mesh = ImmediateMesh.new()
	mesh = _immediate_mesh

func setup_material():
	_material = StandardMaterial3D.new()
	_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	_material.albedo_color = line_color
	_material.vertex_color_use_as_albedo = true
	material_override = _material

func draw_path(path: PackedVector3Array):
	if path.size() < 2:
		return
	
	_immediate_mesh.clear_surfaces()
	
	# Dessiner la ligne principale
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in path.size():
		var vertex = path[i]
		_immediate_mesh.surface_set_color(_get_line_color(i, path.size()))
		_immediate_mesh.surface_add_vertex(vertex)
	_immediate_mesh.surface_end()
	
	# Dessiner les points si activé
	if show_points:
		_draw_path_points(path)

func _draw_path_points(path: PackedVector3Array):
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_POINTS)
	for i in path.size():
		var vertex = path[i]
		_immediate_mesh.surface_set_color(_get_point_color(i, path.size()))
		_immediate_mesh.surface_add_vertex(vertex)
	_immediate_mesh.surface_end()

func _get_line_color(index: int, total: int) -> Color:
	# Optionnel: dégradé de couleur le long du chemin
	var progress = float(index) / float(total - 1)
	return line_color.lerp(Color(line_color.r, line_color.g, line_color.b, 0.8), progress)

func _get_point_color(index: int, total: int) -> Color:
	# Couleur différente pour le premier et dernier point
	if index == 0:
		return Color.GREEN
	elif index == total - 1:
		return Color.RED
	return Color.YELLOW

func clear():
	_immediate_mesh.clear_surfaces()

func add_points(points: PackedVector3Array):
	draw_path(points)
