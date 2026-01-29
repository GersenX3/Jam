extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0
# Variable para el bloqueo de control del wall jump (opcional pero recomendado)
var wall_jump_lock_time: float = 0.0
var timer_wall_jump: float = 0

func _ready() -> void:
	add_to_group("player")

func _process(delta: float) -> void:
	if timer_wall_jump > 0:
		timer_wall_jump -= delta
	print($StateMachine.current_state)
	print(timer_wall_jump)

#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
