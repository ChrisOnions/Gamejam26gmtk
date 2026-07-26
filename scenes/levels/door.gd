extends AnimatedSprite2D
@onready var nokey: RichTextLabel = $Nokey
@onready var door: AnimatedSprite2D = $"."
@onready var static_2d_colision: CollisionShape2D = $StaticBody2D/static_2d_colision
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var sfx_door: AudioStreamPlayer = $sfx_door

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PLAYER and body.has_key:
		door.play("open")
		sfx_door.play()
		static_2d_colision.set_deferred("disabled", true)
		#static_2d_colision.disabled = true
	else:
		nokey.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	nokey.visible = false
