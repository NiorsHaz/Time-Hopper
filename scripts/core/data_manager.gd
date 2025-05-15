extends Node

var DIRECTORY = "res://resources/game/"

signal data_updated

func _init() -> void:
	verify_file(DIRECTORY)

func verify_file(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		var error = DirAccess.make_dir_absolute(path)
		if error != OK:
			push_error("Failed to create directory: %s, Error: %d" % [path, error])
			breakpoint 
	else:
		dir.make_dir(path)
	print("Directory verified: %s" % path)


func load(file_name: String) -> Resource:
	var path = DIRECTORY + file_name + ".tres"
	var loaded_resource = ResourceLoader.load(path)
	emit_signal("data_updated")
	print("Loaded: %s" % path)
	return loaded_resource.duplicate(false)

func save(ressource: Resource, file_name: String):
	var path = DIRECTORY + file_name + ".tres"
	ResourceSaver.save(ressource, path)
	emit_signal("data_updated")
	print("Saved: %s" % path)
