extends Node2D

@onready var sfx_powerup: AudioStreamPlayer = $sfx_powerup

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER:
		body.add_sand(1.0)
		print("New Max Capacity: ", body.max_capacity)
		sfx_powerup.play()
		await sfx_powerup.finished
		queue_free()
