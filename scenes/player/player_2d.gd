extends CharacterBody2D
class_name PLAYER

@export var sprite_2d: Sprite2D
@export var max_capacity: float = 100.0
@export var flow_rate: float = 1.0
@export var leak_rate: float = 1.0
@export var grace_period: float = 3.0
@export var refill_rate: float = 2.0
@export var current_level: int = 1

@onready var canvas_layer: CanvasLayer = $Camera2D/CanvasLayer
@onready var top_bar: ProgressBar = $TopBar
@onready var bottom_bar: ProgressBar = $BottomBar

var side_a_sand: float
var side_b_sand: float

var is_flipped: bool = false
var is_refilling: bool = false
var gameover: bool = false
var grace_time_left: float = 0.0
var is_sand_moving: bool = false

const SPEED = 300.0
var resetbutton = preload("res://scenes/game_over.tscn")

func _ready() -> void:
	side_a_sand = max_capacity / 2.0
	side_b_sand = 0.0
	GameManager.player = self

func _process(delta: float) -> void:
	if side_a_sand <= 0.0 and side_b_sand <= 0.0 and not gameover:
		gameover = true
		print("Spawning reset button")
		var spawnedbutton = resetbutton.instantiate()
		add_child(spawnedbutton)

func _physics_process(delta: float) -> void:
	ui_update()
	handle_sand_mechanics(delta)
	handle_movement()
	
	if Input.is_action_just_pressed("Interact"):
		flip()
	if Input.is_action_just_pressed("load_level0"):
		EventBus.load_level.emit(0)
	if Input.is_action_just_pressed("load_level1"):
		EventBus.load_level.emit(1)
	if Input.is_action_just_pressed("load_level2"):
		EventBus.load_level.emit(2)

func handle_sand_mechanics(delta: float) -> void:
	var prev_a = side_a_sand
	var prev_b = side_b_sand

	if is_refilling:
		if not is_flipped:
			side_a_sand = min(side_a_sand + refill_rate * delta, max_capacity / 2.0)
		else:
			side_b_sand = min(side_b_sand + refill_rate * delta, max_capacity / 2.0)

	if not is_flipped:
		var flow_amount = min(side_a_sand, flow_rate * delta)
		var space_in_b = (max_capacity / 2.0) - side_b_sand
		flow_amount = min(flow_amount, space_in_b)
		
		side_a_sand -= flow_amount
		side_b_sand += flow_amount
	else:
		if side_a_sand > 0.0:
			side_a_sand = max(side_a_sand - leak_rate * delta, 0.0)
		else:
			side_b_sand = max(side_b_sand - leak_rate * delta, 0.0)

	is_sand_moving = (side_a_sand != prev_a) or (side_b_sand != prev_b)

	if side_a_sand <= 0.0 and side_b_sand <= 0.0:
		if grace_time_left == 0.0 and not gameover:
			grace_time_left = grace_period
		else:
			grace_time_left -= delta
			if grace_time_left <= 0.0:
				player_death()
	else:
		grace_time_left = 0.0

func flip() -> void:
	is_flipped = not is_flipped
	
	if sprite_2d:
		sprite_2d.flip_v = is_flipped

	print("Flipped! Inverted (Leaking Side A): ", is_flipped)

func handle_movement() -> void:
	if not is_sand_moving:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		move_and_slide()
		return

	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_UP", "Move_Down")
	if input_dir:
		velocity = input_dir * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()

func add_sand(amount: float = 1.0) -> void:
	max_capacity += amount
	canvas_layer.update_sand_ui()
	if not is_flipped:
		side_a_sand = min(side_a_sand + amount, max_capacity / 2.0)
	else:
		side_b_sand = min(side_b_sand + amount, max_capacity / 2.0)

func start_refill() -> void:
	is_refilling = true

func stop_refill() -> void:
	is_refilling = false

func player_death() -> void:
	EventBus.player_died.emit()
	queue_free()

func ui_update() -> void:
	top_bar.max_value = max_capacity / 2.0
	bottom_bar.max_value = max_capacity / 2.0
	
	if not is_flipped:
		top_bar.value = side_a_sand
		bottom_bar.value = side_b_sand
	else:
		top_bar.value = side_b_sand
		bottom_bar.value = side_a_sand
