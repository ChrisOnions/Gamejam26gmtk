extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER :
		GameManager.player.add_sand(1)
		print(GameManager.player.max_sand)
		self.queue_free()
	pass # Replace with function body.
