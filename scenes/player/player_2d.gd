extends CharacterBody2D
class_name PLAYER

@export var sprite_2d: Sprite2D
@export var max_sand: float = 10.0
@export var drain_rate: float = 1.0     # sand lost per second
@export var refill_rate: float = 4.0    # sand gained per second while in waterfall

var current_sand: float
var is_refilling: bool = false

const SPEED = 300.0

func _ready() -> void:
	current_sand = max_sand
	GameManager.player = self

func _physics_process(delta: float) -> void:
	if is_refilling:
		current_sand = min(current_sand + refill_rate * delta, max_sand)
	else:
		current_sand = max(current_sand - drain_rate * delta, 0.0)
		if current_sand <= 0.0:
			player_death()

	print(current_sand)  # swap for a sprite/UI update later

	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_UP", "Move_Down")
	if input_dir:
		velocity = input_dir * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()

func add_sand():
	max_sand += 1

func start_refill() -> void:
	is_refilling = true

func stop_refill() -> void:
	is_refilling = false

func player_death():
	queue_free()
