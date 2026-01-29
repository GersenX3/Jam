extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0
var LIFE = 100
var last_move

# Timer para evitar que se vuelva a pegar a la pared inmediatamente después de wall jump
var wall_jump_cooldown: float = 0.0
# Duración del cooldown (ajusta según prefieras)
const WALL_JUMP_COOLDOWN_TIME: float = 0.3

# COYOTE TIME: Permite saltar por un breve momento después de salir del suelo
var coyote_time_counter: float = 0.0
const COYOTE_TIME: float = 0.15  # 150ms de gracia para saltar

# JUMP BUFFER: Registra cuando el jugador presiona jump antes de tocar el suelo
var jump_buffer_counter: float = 0.0
const JUMP_BUFFER_TIME: float = 0.15  # 150ms de buffer

func _ready() -> void:
	add_to_group("player")

func _process(delta: float) -> void:
	last_move = sign(Input.get_axis("left", "right")) if Input.get_axis("left", "right") != 0 else last_move
	# Decrementar el timer de cooldown del wall jump
	if wall_jump_cooldown > 0:
		wall_jump_cooldown -= delta
	
	# Decrementar el timer de coyote time
	if coyote_time_counter > 0:
		coyote_time_counter -= delta
	
	# Decrementar el timer de jump buffer
	if jump_buffer_counter > 0:
		jump_buffer_counter -= delta

func hazard():
	LIFE = LIFE - 40
	#mostrar daño jugador
	EventBus.emit("cambio_vida", LIFE)
	if LIFE <= 0:
		_trigger_death()

func vida():
	LIFE = LIFE + 10
	#mostrar daño jugador
	EventBus.emit("cambio_vida", LIFE)
	if LIFE >= 200:
		_trigger_death()

func _trigger_death():
	get_tree().reload_current_scene()
	pass
