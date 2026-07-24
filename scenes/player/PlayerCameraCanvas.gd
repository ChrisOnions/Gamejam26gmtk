extends CanvasLayer

@onready var player_2d: PLAYER = $"../.."
@onready var Sand_label: Label = $Control/Label

func _ready() -> void:
	update_sand_ui()

func update_sand_ui():
	Sand_label.text = str(int(player_2d.max_capacity - 10))
