extends Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@export var speed := 1.0
var hold_time := 0.0
const HOLD_DURATION := 3.0  # 1 second required
var is_holding_escape := false

func _ready() -> void:
	if animation_player.has_animation("play"):
		animation_player.speed_scale = speed
		animation_player.play("play")
	else:
		push_error("Animation 'play' not found in AnimationPlayer")
		

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_RIGHT:
			if animation_player.is_playing():
				animation_player.speed_scale = clamp(animation_player.speed_scale + 1.0, 1.0, 10.0)

func _process(delta: float) -> void:
	if is_holding_escape:
		hold_time += delta
		var time_left = max(0.0, HOLD_DURATION - hold_time)
		$CanvasLayer/Timer.text = "%.1f s" % time_left
		
		if hold_time >= HOLD_DURATION:
			_exit_animation_story()
			hold_time = 0.0
			is_holding_escape = false
			$CanvasLayer/Timer.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_escape"):
			is_holding_escape = true
			$CanvasLayer/Timer.visible = true
			$CanvasLayer/Timer.text = "%.1f s" % HOLD_DURATION
			hold_time = 0.0  # Reset hold time
		if event.is_action_released("ui_escape"):
			is_holding_escape = false
			$CanvasLayer/Timer.visible = false
			hold_time = 0.0

func _exit_animation_story() -> void:
	var error = get_tree().change_scene_to_file("res://scenes/main/worlds/world_hub.tscn")
	if error != OK:
		push_error("Failed to load scene: ", error)
