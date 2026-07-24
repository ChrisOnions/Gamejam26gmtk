extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER:
		body.add_sand(1.0)
		print("New Max Capacity: ", body.max_capacity)
		queue_free()
