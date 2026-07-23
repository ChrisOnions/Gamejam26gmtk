extends CharacterBody2D
class_name PLAYER

@export var sprite_2d: Sprite2D
@export var max_sand: float = 60.0
@export var drain_rate: float = 1.0
@export var refill_rate: float = 2.0
@export var grace_period: float = 3.0
@onready var top_bar_ui: ProgressBar = $TopBar
@onready var bottom_bar_ui: ProgressBar = $BottomBar

var top_sand: float
var bottom_sand: float
var is_empty: bool = false
var is_refilling: bool = false
var grace_time_left: float = 0.0
	
const SPEED = 300.0

func _ready() -> void:
	top_sand = max_sand / 2.0
	bottom_sand = 0.0
	GameManager.player = self

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("load_level1"):
		EventBus.load_level.emit(1)
	if Input.is_action_just_pressed("load_level2"):
		EventBus.load_level.emit(2)
	update_ui()
	if is_refilling:
		bottom_sand = min(bottom_sand + refill_rate * delta, max_sand / 2.0)
		if bottom_sand >= max_sand / 2.0:
			flip()
	elif top_sand > 0.0:
		var amount = min(drain_rate * delta, top_sand)
		top_sand -= amount
		bottom_sand += amount
		is_empty = false
	else:
		if not is_empty:
			is_empty = true
			grace_time_left = grace_period
		else:
			grace_time_left -= delta
			if grace_time_left <= 0.0:
				player_death()

	#print("Top: ", int(top_sand), " Bottom: ", int(bottom_sand), " Grace: ", grace_time_left if is_empty else "-")

	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_UP", "Move_Down")
	if input_dir:
		velocity = input_dir * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()

func add_sand(amount: float = 1.0) -> void:
	max_sand += amount
	bottom_sand = min(bottom_sand + amount, max_sand / 2.0)

func start_refill() -> void:
	if not is_refilling:
		bottom_sand = 0.0
		is_refilling = true

func stop_refill() -> void:
	is_refilling = false

func flip() -> void:
	top_sand = bottom_sand
	bottom_sand = 0.0
	is_empty = false

func player_death():
	queue_free()

func update_ui():
	print(top_bar_ui)
	top_bar_ui.max_value = max_sand/2
	top_bar_ui.value = top_sand
	bottom_bar_ui.max_value = max_sand/2
	bottom_bar_ui.value = bottom_sand
