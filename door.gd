extends Node2D

@export var door_id:int = 0

var is_closed:bool

func _ready() -> void:
	EventBus.open_door.connect(_open)
	EventBus.close_door.connect(_close)
	$StaticBody2D/close.hide()
	print($StaticBody2D/close.visible)
	
func _open(sig_door_id) -> void:
	print($StaticBody2D/close.visible)
	if sig_door_id == door_id:
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
		self.is_closed = false
		$StaticBody2D/close.hide()
		$StaticBody2D/open.show()
		Sfxmanager.play("door")
	
func _close(sig_door_id) -> void:
	if sig_door_id == door_id:
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
		self.is_closed = true
		$StaticBody2D/close.show()
		$StaticBody2D/open.hide()
	
