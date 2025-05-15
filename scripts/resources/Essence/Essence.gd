class_name Essence
extends Resource

@export var type: TypeEssence = TypeEssence.QI
@export var value: int = 10

enum TypeEssence { QI, SOCIABILITY }

static func get_total_value(array: Array[Essence]) -> int:
	return array.reduce(func(acc, essence): return acc + essence.value, 0)
