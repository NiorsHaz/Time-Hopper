extends Node

var SAVE_PATH_FILE = "user://game_data/"
var GAME_PATH_FILE = "res://resources/game/"

var save_id_counter: int = 0

func _ready():
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("game_data"):
		dir.make_dir("game_data")
	
	load_data()

func date_save_file():
	var time = Time.get_datetime_dict_from_system()
	var timestamp = "%04d-%02d-%02d_%02d-%02d-%02d" % [
		time.year, time.month, time.day,
		time.hour, time.minute, time.second
	]
	return timestamp

func save_data():
	save_id_counter += 1
	var save_id = save_id_counter
	var timestamp = date_save_file()
	var save_dir = SAVE_PATH_FILE + "save_%d_%s/" % [save_id, timestamp]
	
	var dir = DirAccess.open(SAVE_PATH_FILE)
	if dir and not dir.dir_exists("save_%d_%s" % [save_id, timestamp]):
		dir.make_dir("save_%d_%s" % [save_id, timestamp])
	
	var dir_game = DirAccess.open(GAME_PATH_FILE)
	if dir_game:
		dir_game.list_dir_begin()
		var file_name = dir_game.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var src_path = GAME_PATH_FILE + file_name
				var dest_path = save_dir + file_name
				var error = dir_game.copy(src_path, dest_path)
				if error == OK:
					print("Copied %s to %s" % [src_path, dest_path])
				else:
					print("Error copying %s: %s" % [src_path, error])
			file_name = dir_game.get_next()
		dir_game.list_dir_end()
	
	print("Sauvegarde créée : %s" % save_dir)

func load_data(save_id: int = -1):
	var dir = DirAccess.open(SAVE_PATH_FILE)
	var save_dirs = []
	
	if dir:
		dir.list_dir_begin()
		var dir_name = dir.get_next()
		while dir_name != "":
			if dir_name.begins_with("save_") and dir.dir_exists(dir_name):
				save_dirs.append(dir_name)
			dir_name = dir.get_next()
		dir.list_dir_end()
	
	if save_dirs.is_empty():
		print("Aucune sauvegarde trouvée.")
		return
	
	save_dirs.sort_custom(func(a, b):
		var id_a = int(a.split("_")[1])
		var id_b = int(b.split("_")[1])
		return id_a > id_b
	)
	
	var dir_to_load = save_dirs[0]
	if save_id != -1:
		for save_dir in save_dirs:
			if save_dir.begins_with("save_%d_" % save_id):
				dir_to_load = save_dir
				break
	
	var dir_save = DirAccess.open(SAVE_PATH_FILE + dir_to_load)
	if dir_save:
		dir_save.list_dir_begin()
		var file_name = dir_save.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var src_path = SAVE_PATH_FILE + dir_to_load + "/" + file_name
				var dest_path = GAME_PATH_FILE + file_name
				var error = dir_save.copy(src_path, dest_path)
				if error == OK:
					print("Restored %s to %s" % [src_path, dest_path])
				else:
					print("Error restoring %s: %s" % [src_path, error])
			file_name = dir_save.get_next()
		dir_save.list_dir_end()
	
	save_id_counter = int(dir_to_load.split("_")[1])
	print("Sauvegarde chargée : %s" % dir_to_load)

func delete_save(save_id: int = -1):
	var dir = DirAccess.open(SAVE_PATH_FILE)
	if not dir:
		print("Erreur : Impossible d'accéder au dossier %s" % SAVE_PATH_FILE)
		return
	
	if save_id == -1:
		dir.list_dir_begin()
		var dir_name = dir.get_next()
		while dir_name != "":
			if dir_name.begins_with("save_") and dir.dir_exists(dir_name):
				var sub_dir = DirAccess.open(SAVE_PATH_FILE + dir_name)
				if sub_dir:
					sub_dir.list_dir_begin()
					var file_name = sub_dir.get_next()
					while file_name != "":
						var error = sub_dir.remove(SAVE_PATH_FILE + dir_name + "/" + file_name)
						if error != OK:
							print("Erreur lors de la suppression de %s" % file_name)
						file_name = sub_dir.get_next()
					sub_dir.list_dir_end()
					dir.remove(SAVE_PATH_FILE + dir_name)
					print("Sauvegarde supprimée : %s" % dir_name)
			dir_name = dir.get_next()
		dir.list_dir_end()
	else:
		dir.list_dir_begin()
		var dir_name = dir.get_next()
		while dir_name != "":
			if dir_name.begins_with("save_%d_" % save_id) and dir.dir_exists(dir_name):
				var sub_dir = DirAccess.open(SAVE_PATH_FILE + dir_name)
				if sub_dir:
					sub_dir.list_dir_begin()
					var file_name = sub_dir.get_next()
					while file_name != "":
						var error = sub_dir.remove(SAVE_PATH_FILE + dir_name + "/" + file_name)
						if error != OK:
							print("Erreur lors de la suppression de %s" % file_name)
						file_name = sub_dir.get_next()
					sub_dir.list_dir_end()
					dir.remove(SAVE_PATH_FILE + dir_name)
					print("Sauvegarde supprimée : %s" % dir_name)
				break
			dir_name = dir.get_next()
		dir.list_dir_end()
