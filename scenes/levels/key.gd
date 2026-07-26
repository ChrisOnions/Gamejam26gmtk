extends Sprite2D

@onready var sfx_key: AudioStreamPlayer = $sfx_key

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER:
		body.has_key = true
		Sfxmanager.play("key")
		self.queue_free()
