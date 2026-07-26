extends Control
const MAIN = preload("uid://dq11kn2vyrvdt")
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var music_slider: HSlider = $Options_panel/VBoxContainer/Music_Slider
@onready var sfx_slider: HSlider = $Options_panel/VBoxContainer/sfx_Slider
@onready var box_container: BoxContainer = $BoxContainer
@onready var options_panel: BoxContainer = $Options_panel
@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")
func _ready() -> void:
	
	rich_text_label.text = "[wave amp=20.0 freq=10.0][color=wheat]Sands of Flippy[/color][/wave]"
	MusicManager.stop_music()
	
	$BoxContainer/VBoxContainer/Start_B.mouse_entered.connect(_on_button_hover)
	$BoxContainer/VBoxContainer/Options_B.mouse_entered.connect(_on_button_hover)
	$BoxContainer/VBoxContainer/Exit_B.mouse_entered.connect(_on_button_hover)
	$Options_panel/VBoxContainer/Back_B.mouse_entered.connect(_on_button_hover)
	
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	
func _on_button_hover() -> void:
	hover_sound.play()
	
func _on_start_b_button_down() -> void:
	Sfxmanager.play("click")
	get_tree().change_scene_to_packed(MAIN)

func _on_options_b_button_down() -> void:
	Sfxmanager.play("click")
	box_container.visible = false
	options_panel.visible = true
	print(DisplayServer.window_get_size())

func _on_exit_b_button_down() -> void:
	Sfxmanager.play("click")
	get_tree().quit()

func _on_back_b_button_down() -> void:
	Sfxmanager.play("click")
	box_container.visible = true
	options_panel.visible = false

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
