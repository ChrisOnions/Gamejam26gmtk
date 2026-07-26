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
@onready var sand_bars: Node2D = $SandBars # Parent node holding the texture bar
@onready var sand_bar_top: TextureProgressBar = $SandBars/SandBarTop
@onready var sand_bar_bottum: TextureProgressBar = $SandBars/SandBarBottum

var side_top_sand: float:
	set(value):
		side_top_sand = value
		sand_bar_top.value = side_top_sand / (max_capacity / 2)
		
		
var side_bottum_sand: float:
	set(value):
		side_bottum_sand = value
		sand_bar_bottum.value = side_bottum_sand / (max_capacity / 2)

var is_flipping: bool = false
var is_hole_on_top: bool = true
var is_refilling: bool = false
var gameover: bool = false
var grace_time_left: float = 0.0
var is_sand_moving: bool = false
var has_key: bool = false

const SPEED = 300.0
var resetbutton = preload("res://scenes/game_over.tscn")

func _ready() -> void:
	side_top_sand = max_capacity / 2.0
	side_bottum_sand = 0.0
	GameManager.player = self
	MusicManager.play_gameplay()
	$AnimatedSprite2D.sprite_frames.set_animation_loop("Flip", false)
	
	# Initialize sand_bar properties
	sand_bar_top.max_value = 1
	sand_bar_bottum.max_value = 1
	sand_bar_top.step = 0.05
	sand_bar_bottum.step = 0.05
	sand_bar_top.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP
	sand_bar_bottum.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP

func _process(delta: float) -> void:
	if side_top_sand <= 0 and not gameover:
		gameover = true
		MusicManager.stop_music()
		print("Spawning reset button")
		var spawnedbutton = resetbutton.instantiate()
		add_child(spawnedbutton)

func _physics_process(delta: float) -> void:
	#ui_update()
	handle_sand_mechanics(delta)
	MusicManager.update_intensity(side_top_sand + side_bottum_sand, max_capacity)
	handle_movement()
	
	if Input.is_action_just_pressed("Interact"):
		flip()
	if Input.is_action_just_pressed("load_level0"):
		EventBus.load_level.emit(0)
	if Input.is_action_just_pressed("load_level1"):
		EventBus.load_level.emit(1)
	if Input.is_action_just_pressed("load_level2"):
		EventBus.load_level.emit(2)
	if Input.is_action_just_pressed("load_level3"):
		EventBus.load_level.emit(3)
	if Input.is_action_just_pressed("load_level4"):
		EventBus.load_level.emit(4)

func handle_sand_mechanics(delta: float) -> void:
	side_top_sand -= flow_rate*delta  # removs sand from top
	
	if not is_hole_on_top:  # loosing sand
		side_bottum_sand -= leak_rate*delta
		if side_bottum_sand < 0:
			side_bottum_sand = 0
	
	if is_refilling:  # refils the sand
		side_top_sand += refill_rate*delta
		if side_top_sand >= max_capacity / 2:
			side_top_sand = max_capacity / 2
		
	if side_top_sand <= 0.0:
		side_top_sand = 0.0
		if side_bottum_sand <= 0.0:
			if grace_time_left == 0.0 and not gameover:
				grace_time_left = grace_period
			else:
				grace_time_left -= delta
				if grace_time_left <= 0.0:
					player_death()
		else:
			flip()
	else:
		grace_time_left = 0.0
		
	side_bottum_sand += flow_rate*delta  # add sand top bottum
	if side_bottum_sand >= max_capacity / 2:
		side_bottum_sand = max_capacity / 2 
		
	#temp
	side_bottum_sand = side_bottum_sand
	side_top_sand = side_top_sand
		
	print(side_top_sand, "    ", side_bottum_sand, "   ", max_capacity, "    ", is_hole_on_top)
	
func flip() -> void:
	if is_flipping:
		return
		
	var temp_bottum_sand = side_bottum_sand  # flpis the sand
	side_bottum_sand = side_top_sand
	side_top_sand = temp_bottum_sand
	
	is_flipping = true
	is_hole_on_top = not is_hole_on_top
	
	sand_bars.rotation = 3.14  # in radians
	$AnimatedSprite2D.play("Flip")
	$AnimatedSprite2D.flip_h = false
	for i in range(4):
		if i == 0:
			sand_bars.global_position += Vector2(0, 10)
		await $AnimatedSprite2D.frame_changed
		sand_bars.rotation += 3.14 / 4
	#await $AnimatedSprite2D.animation_finished
	sand_bars.rotation = 0
	sand_bars.global_position -= Vector2(0, 10)

	is_flipping = false

	EventBus.player_flip.emit()

func handle_movement() -> void:
	if is_flipping:
		return
		
	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_UP", "Move_Down")
	if input_dir:
		velocity = input_dir * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	update_animation(input_dir)
	move_and_slide()

func add_sand(amount: float = 1.0) -> void:
	max_capacity += amount
	if canvas_layer and canvas_layer.has_method("update_sand_ui"):
		canvas_layer.update_sand_ui()
		
	side_top_sand += amount
	if side_top_sand >= max_capacity / 2:
		side_top_sand = max_capacity

func start_refill() -> void:
	is_refilling = true

func stop_refill() -> void:
	is_refilling = false

func player_death() -> void:
	EventBus.player_died.emit()
	queue_free()

## Rotates the Node2D parent 180 degrees over a duration, updates fill mode, and resets rotation.
func animate_bar_rotation(duration: float = 9.1) -> void:
	sand_bars.rotation_degrees = 180.0

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Spin 180 degrees
	tween.tween_property(sand_bars, "rotation_degrees", 0, duration)
	
	# Swap fill mode halfway through or at the end to match visual direction, then reset transform
	tween.tween_callback(func():
		sand_bars.rotation_degrees = 0.0
	)
	

func update_animation(input_dir: Vector2) -> void:
	if is_flipping:
		return
	# Choose suffix based on flipped state
	var suffix: String = "" if is_hole_on_top else "_hole_up"
	# Priority given to dominant movement direction
	if input_dir != Vector2.ZERO:
		if abs(input_dir.x) > abs(input_dir.y):
			if input_dir.x > 0:
				$AnimatedSprite2D.play("walk_left")
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.play("walk_left")
				$AnimatedSprite2D.flip_h = false
		else:
			if input_dir.y > 0:
				$AnimatedSprite2D.play("walk_down" + suffix)
				$AnimatedSprite2D.flip_h = false
			else:
				$AnimatedSprite2D.play("walk_up" + suffix)
				$AnimatedSprite2D.flip_h = false
	else:
		# Return to appropriate idle animation when stopping
		$AnimatedSprite2D.play("idle" + suffix)
		$AnimatedSprite2D.flip_h = false
