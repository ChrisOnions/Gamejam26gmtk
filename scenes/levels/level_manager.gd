extends Node2D
class_name LevelManager

@export var current_level:int = 0  # level o is the tutorial

func _ready() -> void:
	EventBus.load_level.connect(on_load_level)  # makes ti so when load_level is cal current_level is opptated
	GameManager.level_manager = self
	
func _process(delta: float) -> void:
	pass
	
func on_load_level(level_id:int) -> void:
	current_level = level_id
