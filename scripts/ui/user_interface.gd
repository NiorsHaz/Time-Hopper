extends CanvasLayer

@onready var sociability_bar: ProgressBar = %SociabilityBar
@onready var qi_bar: ProgressBar = %QIBar

@export var Player : Player 

func _ready():
	DataManager.connect("data_updated", Callable(self, "_on_data_updated"))
	_on_data_updated()

func _on_data_updated():
	var qi: Array[Essence] = Player.Player_data.filtre_essences('QI', true)
	qi_bar.value = Essence.get_total_value(qi)

	var Sociability: Array[Essence] = Player.Player_data.filtre_essences('SOCIABILITY', true)
	sociability_bar.value = Essence.get_total_value(Sociability)
	
	
