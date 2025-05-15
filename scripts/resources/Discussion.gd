class_name Discussion
extends Resource

@export var dialogue_resource: DialogueResource
@export var rewards: Array[Essence]
@export var hystory_reward: Array[Character]

func give_reward(character: Character) -> bool:
	var success = false
	if !hystory_reward.has(character):
		success = true
		hystory_reward.append(character)
		for reward in rewards:
			character.essences.append(reward)
			character.save()

	return success
