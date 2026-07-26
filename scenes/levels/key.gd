extends Sprite2D

@onready var sfx_pickup: AudioStreamPlayer = $sfx_key

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER:
		body.has_key = true
		
		sfx_pickup.play()
		await sfx_pickup.finished
		self.queue_free()
