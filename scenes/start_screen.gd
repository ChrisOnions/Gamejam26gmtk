extends Control
const MAIN = preload("uid://dq11kn2vyrvdt")


func _on_start_b_button_down() -> void:
	get_tree().change_scene_to_packed(MAIN)


func _on_options_b_button_down() -> void:
	print(DisplayServer.window_get_size())

func _on_exit_b_button_down() -> void:
	get_tree().quit()
