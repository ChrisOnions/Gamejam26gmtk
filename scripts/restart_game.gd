extends Node

var player: CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onbuttonpressed() -> void:
	#player = get_node("../Player2d")
	EventBus.load_level.emit(player.current_level)
	queue_free()
