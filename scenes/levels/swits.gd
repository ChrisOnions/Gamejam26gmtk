extends Node2D

@export var door_id_open:int = 0
var is_player_on:bool = false

func _ready() -> void:
	EventBus.player_flip.connect(_player_flipt)
	
func _player_flipt() -> void:
	print("player flipt", is_player_on)
	if is_player_on:
		EventBus.open_door.emit(door_id_open)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER:
		is_player_on = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PLAYER:
		is_player_on = false
