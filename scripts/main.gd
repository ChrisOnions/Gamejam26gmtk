extends Node

const PLAYER_2D = preload("uid://bts4on5khvdh2")

func _ready() -> void:
	Spawn_Player()
	pass

func Spawn_Player():
	var player = PLAYER_2D.instantiate()
	add_child(player)
