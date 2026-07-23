extends Node2D

@export var id:int = 2  # is const but do not know how to export and const
@export var is_load:bool

func _ready() -> void:
	EventBus.load_level.connect(_on_load_level)
	is_load = false
	for obj in get_children():
		obj.hide()
		obj.set_process(false)

func _process(delta: float) -> void:
	pass

func _on_load_level(level_id:int) -> void:
	if level_id == id:
		self.lode_level()
	else:
		self.disable_level()
		
func disable_level() -> void:  # disable all the childer of the level
	is_load = false
	for obj in get_children():
		obj.hide()
		obj.set_process(false)
	
func lode_level() -> void:  # loads all the childer of the level
	is_load = true
	for obj in get_children():
		obj.show()
		obj.set_process(true)
