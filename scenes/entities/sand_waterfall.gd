extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER :#and not body.Sand_refilling:
		body.start_refill()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PLAYER:
		body.stop_refill()
