extends Control
const MAIN = preload("uid://dq11kn2vyrvdt")
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound

func _ready() -> void:
	rich_text_label.text = "[wave amp=20.0 freq=10.0][color=wheat]Game name here[/color][/wave]"
	
	MusicManager.stop_music()

	$BoxContainer/VBoxContainer/Start_B.mouse_entered.connect(_on_button_hover)
	$BoxContainer/VBoxContainer/Options_B.mouse_entered.connect(_on_button_hover)
	$BoxContainer/VBoxContainer/Exit_B.mouse_entered.connect(_on_button_hover)
	
func _on_button_hover() -> void:
	hover_sound.play()
	
func _on_start_b_button_down() -> void:
	click_sound.play()
	get_tree().change_scene_to_packed(MAIN)

func _on_options_b_button_down() -> void:
	click_sound.play()
	print(DisplayServer.window_get_size())

func _on_exit_b_button_down() -> void:
	click_sound.play()
	get_tree().quit()
