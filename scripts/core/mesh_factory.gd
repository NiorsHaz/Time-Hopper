extends Object
class_name MeshFactory

static func simple_grass(lod_level: int = 0) -> Mesh:
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	# Ajuster la taille des brins selon le LOD
	var scale = 1.0
	if lod_level == 1:
		scale = 0.8
	elif lod_level == 2:
		scale = 0.6
	elif lod_level >= 3:
		scale = 0.4
	
	var width = 0.5 * scale # Largeur de la base
	var height = 1.0 * scale # Hauteur du brin
	
	# Base
	verts.push_back(Vector3(-width, 0.0, 0.0))
	uvs.push_back(Vector2(0.0, 0.0))
	
	verts.push_back(Vector3(width, 0.0, 0.0))
	uvs.push_back(Vector2(1.0, 0.0))
	
	# Sommet
	verts.push_back(Vector3(0.0, height, 0.0))
	uvs.push_back(Vector2(0.5, 1.0))
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_TEX_UV2] = uvs
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.custom_aabb = AABB(Vector3(-0.5, 0.0, -0.5), Vector3(1.0, 1.0, 1.0))
	
	return mesh
