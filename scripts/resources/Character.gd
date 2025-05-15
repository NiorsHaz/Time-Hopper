class_name Character
extends Resource

@export var display_name: String = ""
@export var portrait: Texture2D
@export var description: String = ""
@export var role: String = ""
@export var relations: Array[Relation]
@export var essences:  Array[Essence]
@export var discussion: Discussion

@export var position : Vector3

func set_position(p : Vector3):
	position = p

func have_relations(character: Character) -> bool:
	return relations.any(func(r): return r.character == character)

func create_relations(character: Character):
	var relation = Relation.new()
	relation.character = character
	relations.append(relation)
	save()
	
func filtre_essences(type: String, return_array: bool = false) -> Variant:
	if not type in Essence.TypeEssence.keys():
		return null
	var enum_type = Essence.TypeEssence[type]
	var filtered = essences.filter(func(essence): return essence.type == enum_type)
	if return_array:
		return filtered
	return filtered.size()
	
func create_essences(type: String, value: int):
	if not type in Essence.TypeEssence.keys():
		return []
	var enum_type = Essence.TypeEssence[type]
	var essence = Essence.new()
	essence.type = enum_type
	essence.value = value
	essences.append(essence)
	save()
	
func save():
	DataManager.save(self, resource_name)
