extends Node


var sounds := {
	"door": preload("res://assets/Audio/SFX/sfx_door.wav"),
	"key": preload("res://assets/Audio/SFX/sfx_key.wav"),
	"waterfall": preload("res://assets/Audio/SFX/sfx_waterfall.wav"),
	"sand": preload("res://assets/Audio/SFX/sfx_sand.wav"),
	"landing": preload("res://assets/Audio/SFX/Landing.wav"),
	"footstep": preload("res://assets/Audio/SFX/sfx_footsteps.wav"),
	"exit": preload("res://assets/Audio/SFX/sfx_exit.wav"),
	"bigdoor": preload("res://assets/Audio/SFX/sfx_bigdoor.wav"),

}

var volumes := {
	"door": 0.0,
	"waterfall": -10.0,
	"key": 0.0,
	"powerup": -7.0,
	"footstep": -20.0 
}

func play(name: String) -> void:
	if not sounds.has(name):
		push_warning("No sound called: " + name)
		return
	var p := AudioStreamPlayer.new()
	add_child(p)
	p.stream = sounds[name]
	p.volume_db = volumes.get(name, 0.0)
	p.bus = "SFX"
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
	p.volume_db = volumes.get(name, 0.0)
	p.bus = "SFX"
	p.play()
	_loops[name] = p

func stop_loop(name: String) -> void:
	if _loops.has(name) and is_instance_valid(_loops[name]):
		_loops[name].queue_free()
		_loops.erase(name)
