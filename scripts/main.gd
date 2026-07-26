extends Node

const PLAYER_2D = preload("uid://bts4on5khvdh2")
#@onready var gpu_particles_2d: GPUParticles2D = $level_manager/tutorial/GPUParticles2D

func _ready() -> void:
	Spawn_Player()
	EventBus.load_level.emit(0)
#func _physics_process(delta: float) -> void:
	#gpu_particles_2d.visible = true

func Spawn_Player():
	var player = PLAYER_2D.instantiate()
	add_child(player)
	player.global_position = Vector2(-500,150)
