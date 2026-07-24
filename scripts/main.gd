extends Node

const PLAYER_2D = preload("uid://bts4on5khvdh2")

func _ready() -> void:
	Spawn_Player()
	EventBus.load_level.emit(0)

func Spawn_Player():
	var player = PLAYER_2D.instantiate()
	add_child(player)
	player.global_position = Vector2(-500,200)
