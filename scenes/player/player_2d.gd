extends CharacterBody2D

@export var sprite_2d: Sprite2D 
var Player_2d : CharacterBody2D 


const SPEED = 300.0

func _ready() -> void:
	GameManager.player = self

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact"):
		print("Interacted with ...")
	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_UP", "Move_Down")
	if input_dir:
		velocity = input_dir * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()
