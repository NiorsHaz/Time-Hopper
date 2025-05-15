extends GridMap

# Rayon de 5 mètres
@export var radius: float = 5.0


func _ready():
	update_visible_tiles()

func _process(delta):
	if game_manager and game_manager.player:
		update_visible_tiles()

func update_visible_tiles():
	if not game_manager or not game_manager.player:
		return
	
	var center_position = game_manager.player.position
	
	var cells = get_used_cells()
	
	for cell in cells:
		var cell_world_pos = to_global(map_to_local(cell))
		
		var distance = center_position.distance_to(cell_world_pos)
		
		if distance <= radius:
			set_cell_item(cell, get_cell_item(cell))
		else:
			set_cell_item(cell, -1)
