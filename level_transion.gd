extends Node2D

var level_id_lable:Label
var completed_lable:Label

func _ready() -> void:
	EventBus.level_transision_screen.connect(start_loding_level)
	level_id_lable = $"level id"
	completed_lable = $compleated
	level_id_lable.hide()
	completed_lable.hide()
	level_id_lable.z_index = 100 # top be on top
	completed_lable.z_index = 100
	
func start_loding_level(id:int) -> void:
	EventBus.load_level.emit(id)
	level_id_lable.text = "level" + str(id-1)
	level_id_lable.show()
	await get_tree().create_timer(0.4).timeout
	completed_lable.show()
	await get_tree().create_timer(0.8).timeout
	level_id_lable.hide()
	completed_lable.hide()
	
	
