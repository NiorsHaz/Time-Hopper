extends Area3D

# === PARAMÈTRES ===
@export var dialogue_start: String = "start"
@export var dialogue_interface: PackedScene
@export var dialogue_position: Marker3D
@export var character: Character

func action() -> void:
	if dialogue_interface and dialogue_position:
		var dialogue_ui = dialogue_interface.instantiate()
		dialogue_position.add_child(dialogue_ui)
		if dialogue_ui.has_method("start"):
			dialogue_ui.start(character.discussion.dialogue_resource, dialogue_start)
