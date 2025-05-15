extends Control

@export var in_time : float = 0.5
@export var fade_in_time : float = 1.5
@export var pause_time : float = 1.5
@export var fade_out_time : float = 1.5
@export var out_time : float = 0.5

const MAIN_BALLON = preload("res://dialogue/UI/main_ballon.tscn")
@onready var splash_screen_container: CenterContainer = %SplashScreenContainer

var splash_screens : Array

func _ready() -> void:
	text_dialogue()
	get_screen()
	fade()

func text_dialogue() -> void:
	var dialogue_ui = MAIN_BALLON.instantiate()
	add_child(dialogue_ui)
	dialogue_ui.start(load("res://dialogue/main.dialogue"), "start")

func get_screen() -> void:
	splash_screens = splash_screen_container.get_children()
	for screen in splash_screens:
		screen.modulate.a = 0.0

func fade() -> void:
	for screen in splash_screens:
		var tween  = self.create_tween()
		tween.tween_interval(in_time)
		tween.tween_property(screen, "modulate:a", 1.0, fade_in_time)
		tween.tween_interval(pause_time)
		tween.tween_property(screen, "modulate:a", 0.0, fade_out_time)
		tween.tween_interval(out_time)
		await  tween.finished
	end_splash()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.is_action_pressed("ui_escape") or event.is_action_pressed("ui_enter") or event.is_action_pressed("ui_space"):
			end_splash()
	
func end_splash():
	#game_manager.game_controller.change_2d_scene("res://scenes/ui/storyScreenManager.tscn")
	game_manager.game_controller.change_gui_scene("res://scenes/ui/game_menu.tscn")
