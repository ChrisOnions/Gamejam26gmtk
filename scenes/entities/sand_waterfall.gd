extends Node2D

@onready var sfx_waterfall: AudioStreamPlayer = $sfx_waterfall

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER :#and not body.Sand_refilling:
		print("filling sand")
		body.start_refill()
		sfx_waterfall.play()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PLAYER:
		body.stop_refill()
		sfx_waterfall.stop()
