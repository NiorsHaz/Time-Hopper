class_name Relation
extends Resource

@export var character: Character
@export var type_of_relations: TypeOfRelations = TypeOfRelations.NONE

enum TypeOfRelations { NONE, FRIENDSHIP, NEUTRAL, RIVAL }
