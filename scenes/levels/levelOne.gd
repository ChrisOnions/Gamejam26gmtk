extends Node2D
class_name Level

@export var id:int
var is_load:bool

func _ready() -> void:
	EventBus.load_level.connect(_on_load_level)
	is_load = false
	for obj in get_children():
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		if obj is CanvasItem:
			obj.visible = false

func _on_load_level(level_id:int) -> void:
	if level_id == id:
		self.lode_level()
	else:
		self.disable_level()
		
func disable_level() -> void:  # disable all the childer of the level
	is_load = false
	for obj in get_all_children(self):
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		if obj is CanvasItem:
			obj.visible = false
	
func lode_level() -> void:  # loads all the childer of the level
	is_load = true
	for obj in get_all_children(self): 
		obj.process_mode = Node.PROCESS_MODE_INHERIT
		if obj is CanvasItem:
			obj.visible = true
	
func get_all_children(node:Node) -> Array[Node]:
	var resolt:Array[Node] = []
	for childe in node.get_children():
		resolt.append(childe)
		resolt.append_array(get_all_children(childe))
	return resolt
		
