extends CharacterBody2D
class_name PLAYER


@export var sprite_2d: Sprite2D 

@onready var head_timer: Timer = $Head_Timer
@onready var flip_timer: Timer = $Flip_Timer

@export var max_sand: float
var current_sand: float

var Sand_refilling : bool = true  

var Player_2d : CharacterBody2D 
const SPEED = 300.0

func _ready() -> void:
	current_sand = max_sand
	Sand_refilling = false
	GameManager.player = self

func _physics_process(delta: float) -> void:
	if flip_timer.time_left > 0:
		print("Flip - " , int(flip_timer.time_left))
	elif head_timer.time_left > 0:
		print("Head - " ,int(head_timer.time_left))
	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_UP", "Move_Down")
	if input_dir:
		velocity = input_dir * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()

func add_sand():
	max_sand += 1

func refill_sand():
	flip_timer.stop()
	Sand_refilling = true
	while Sand_refilling and current_sand < max_sand:
		current_sand += 0.5
		if current_sand >= max_sand:
			current_sand = max_sand
			Sand_refilling = false
		await get_tree().create_timer(0.05).timeout
	head_timer.start(max_sand)

func player_death():
	queue_free()

func _on_head_timer_timeout() -> void:
	head_timer.stop()
	flip_timer.start(max_sand)

func _on_flip_timer_timeout() -> void:
	flip_timer.stop()
	player_death()
