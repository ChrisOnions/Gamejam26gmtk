extends Node


var sounds := {
	"door": preload("res://assets/Audio/SFX/sfx_door.wav"),
	"key": preload("res://assets/Audio/SFX/sfx_key.wav"),
	"waterfall": preload("res://assets/Audio/SFX/sfx_waterfall.wav"),
	"sand": preload("res://assets/Audio/SFX/sfx_sand.wav"),
	"landing": preload("res://assets/Audio/SFX/Landing.wav"),

}

var volumes := {
	"door": 0.0,
	"waterfall": 0.0,
	"key": 0.0,
	"powerup": -5.0,
}

func play(name: String) -> void:
	if not sounds.has(name):
		push_warning("No sound called: " + name)
		return
	var p := AudioStreamPlayer.new()
	add_child(p)
	p.stream = sounds[name]
	p.play()
	p.finished.connect(p.queue_free)

var _loops := {}

func play_loop(name: String) -> void:
	if not sounds.has(name):
		push_warning("No sound called: " + name)
		return
	if _loops.has(name) and is_instance_valid(_loops[name]):
		return  # already playing, don't stack
	var p := AudioStreamPlayer.new()
	add_child(p)
	p.stream = sounds[name]
	p.play()
	_loops[name] = p

func stop_loop(name: String) -> void:
	if _loops.has(name) and is_instance_valid(_loops[name]):
		_loops[name].queue_free()
		_loops.erase(name)
