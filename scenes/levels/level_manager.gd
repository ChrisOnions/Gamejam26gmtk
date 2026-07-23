extends Node2D

@export var current_level:int = 0

func _ready() -> void:
	EventBus.load_level.connect(on_load_level)

func _process(delta: float) -> void:
	pass
	
func on_load_level(level_id:int) -> void:
	current_level = level_id
