extends CharacterBody2D
class_name PLAYER

@export var sprite_2d: Sprite2D
@export var max_sand: float = 10.0
@export var flow_rate: float = 1.0   
@export var leak_rate: float = 1.0    
@export var grace_period: float = 3.0
@export var refill_rate: float = 2.0

@onready var top_bar: ProgressBar = $TopBar
@onready var bottom_bar: ProgressBar = $BottomBar

var is_refilling: bool = false
var top_sand: float
var bottom_sand: float
var leak_on_top: bool = true
var is_empty: bool = false
var grace_time_left: float = 0.0

const SPEED = 300.0

func _ready() -> void:
	top_sand = max_sand
	bottom_sand = 0.0
	GameManager.player = self

func _physics_process(delta: float) -> void:
	uiupdate()
	var moved = min(flow_rate * delta, top_sand)
	top_sand -= moved
	bottom_sand += moved

	if is_refilling:
		top_sand = min(top_sand + refill_rate * delta, max_sand)

	if not leak_on_top:
		bottom_sand = max(bottom_sand - leak_rate * delta, 0.0)

	if top_sand <= 0.0:
		flip()

	if top_sand <= 0.0 and bottom_sand <= 0.0:
		if not is_empty:
			is_empty = true
			grace_time_left = grace_period
		else:
			grace_time_left -= delta
			if grace_time_left <= 0.0:
				player_death()
	else:
		is_empty = false

	#print("Top: ", int(top_sand), " Bottom: ", int(bottom_sand), " Leak on top: ", leak_on_top, " Grace: ", grace_time_left if is_empty else "-")

	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_UP", "Move_Down")
	if input_dir:
		velocity = input_dir * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()

func add_sand(amount: float = 1.0) -> void:
	max_sand += amount
	top_sand = min(top_sand + amount, max_sand)

func flip() -> void:
	leak_on_top = not leak_on_top
	var temp = top_sand
	top_sand = bottom_sand
	bottom_sand = temp

func start_refill() -> void:
	if not leak_on_top:
		flip()
	is_refilling = true

func stop_refill() -> void:
	is_refilling = false
func player_death():
	queue_free()

func uiupdate():
	top_bar.max_value = max_sand / 2
	bottom_bar.max_value = max_sand/ 2 
	top_bar.value= top_sand
	bottom_bar.value = bottom_sand
