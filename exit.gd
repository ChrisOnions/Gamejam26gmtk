extends Node2D

func _ready() -> void:
	if !get_parent() is Level:
		print("exit has to child of a level")
		queue_free()
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER:
		if GameManager.level_manager.current_level != get_parent().id:  # bicos of this exit has to be the child of a 
			return
		print("loding next level")
		body.position = Vector2(0, 0)  # reset the plaer posion for the next level
		EventBus.level_transision_screen.emit(GameManager.level_manager.current_level+1)
		print(GameManager.level_manager.current_level)
