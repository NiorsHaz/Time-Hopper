extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var callable: Callable = Callable(self, "test")

@onready var action_lable: RichTextLabel = %Action
@onready var titre_action: RichTextLabel = %TitreAction


func _ready() -> void:
	visible = false
	
func open_ui(is_open: bool) -> void:
	if is_open:
		visible = true
		animation_player.play("Open")
	else:
		animation_player.play("Close")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Open":
		animation_player.pause()
	elif anim_name == "Close":
		visible = false

func called_action(action: Callable) -> void:
	if action.is_valid():
		action.call()

func _on_button_pressed() -> void:
	called_action(callable)

func test() -> void:
	print("Action executed!")
