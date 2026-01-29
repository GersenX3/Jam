extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

# Timer para evitar que se vuelva a pegar a la pared inmediatamente después de wall jump
var wall_jump_cooldown: float = 0.0
# Duración del cooldown (ajusta según prefieras)
const WALL_JUMP_COOLDOWN_TIME: float = 0.3

func _ready() -> void:
	add_to_group("player")

func _process(delta: float) -> void:
	# Decrementar el timer de cooldown del wall jump
	if wall_jump_cooldown > 0:
		wall_jump_cooldown -= delta
