extends Node2D

const id:int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.load_level.connect(_on_load_level)
	for obj in get_children():
		obj.hide()
		obj.set_process(false)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_load_level(level_id:int) -> void:
	print(1)
	if level_id == id:
		self.lode_level()
	else:
		self.disable_level()
		
func disable_level() -> void:  # disable all the childer of the level
	for obj in get_children():
		obj.hide()
		obj.set_process(false)
	
func lode_level() -> void:  # loads all the childer of the level
	
	for obj in get_children():
		obj.show()
		obj.set_process(true)
