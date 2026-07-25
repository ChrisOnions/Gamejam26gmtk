extends CharacterBody2D
class_name PLAYER

@export var sprite_2d: Sprite2D
@export var max_capacity: float = 100.0
@export var flow_rate: float = 1.0
@export var leak_rate: float = 0.40
@export var grace_period: float = 3.0
@export var refill_rate: float = 2.0
@export var current_level: int = 1

@onready var canvas_layer: CanvasLayer = $Camera2D/CanvasLayer
@onready var sand_bars: Node2D = $SandBars # Ensure this matches your Node2D's exact name in the scene tree
@onready var top_bar: TextureProgressBar = $SandBars/TopBar
@onready var bottom_bar: TextureProgressBar = $SandBars/BottomBar

var side_a_sand: float
var side_b_sand: float

var is_flipping: bool = false
var is_flipped: bool = false
var is_refilling: bool = false
var gameover: bool = false
var grace_time_left: float = 0.0
var is_sand_moving: bool = false
var has_key: bool = false

const SPEED = 300.0
var resetbutton = preload("res://scenes/game_over.tscn")

func _ready() -> void:
	side_a_sand = max_capacity / 2.0
	side_b_sand = 0.0
	GameManager.player = self
	$AnimatedSprite2D.sprite_frames.set_animation_loop("Flip", false)

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
	# Ignore flip inputs if already mid-animation
	if is_flipping:
		return
		
	is_flipping = true
	is_flipped = not is_flipped
	
	# Start turning the Node2D parent
	animate_bar_rotation(1.0)
	
	$AnimatedSprite2D.play("Flip")
	await $AnimatedSprite2D.animation_finished
	
	$AnimatedSprite2D.play("idle hole up")
	is_flipping = false # Allow player to flip again

	print("Flipped! Inverted (Leaking Side A): ", is_flipped)
	EventBus.player_flip.emit()

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
	
	# Since rotation snaps back to 0.0, top_bar remains physical TOP
	# and bottom_bar remains physical BOTTOM on screen.
	if not is_flipped:
		top_bar.value = side_a_sand
		bottom_bar.value = side_b_sand
	else:
		top_bar.value = side_b_sand
		bottom_bar.value = side_a_sand

## Rotates the Node2D parent 180 degrees over a duration, then snaps back to 0.
func animate_bar_rotation(duration: float = 1.1) -> void:
	# Reset starting point to 0.0 so degrees don't build up endlessly
	sand_bars.rotation_degrees = 0.0

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# 1. Smoothly spin 180 degrees
	tween.tween_property(sand_bars, "rotation_degrees", 180.0, duration)
	
	# 2. Instantly reset rotation back to 0.0 at the end of the spin
	tween.tween_callback(func(): sand_bars.rotation_degrees = 0.0)
