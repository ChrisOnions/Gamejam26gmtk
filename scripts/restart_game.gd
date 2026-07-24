extends Node
@onready var game_over: Control = $"."

var player: CharacterBody2D

func _ready() -> void:
	player = GameManager.player
	##EventBus.player_died.connect()

func onbuttonpressed() -> void:
	EventBus.load_level.emit(player.current_level)
	queue_free()
