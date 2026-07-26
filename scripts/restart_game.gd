extends Node
@onready var game_over: Control = $"."

var player: CharacterBody2D

func _ready() -> void:
	player = GameManager.player
	##EventBus.player_died.connect()

func onbuttonpressed() -> void:
	get_tree().reload_current_scene()
	#EventBus.load_level.emit(player.current_level)
	#queue_free()


func _on_exit_b_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
	#get_tree().change_scene_to_packed(start_screen)
	pass # Replace with function body.
