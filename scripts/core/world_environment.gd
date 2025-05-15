@tool
extends WorldEnvironment

@onready var sky_material = %WorldEnvironment.environment.sky.sky_material

func _process(delta):
	sky_material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
