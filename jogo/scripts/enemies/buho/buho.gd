# OwlEnemy.gd
extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var detection_area: Area2D = $DetectionArea
@onready var damage_area: Area2D = $DamageArea  # Tu área de daño existente

const DIVE_ACCELERATION = 400.0
const MAX_DIVE_SPEED = 2000.0
const RETURN_SPEED = 600.0  # Mitad de la velocidad máxima de diving
const VISION_CONE_ANGLE = 360.0  # Ángulo del cono de visión (ajustable)

var LIFE = 1
var initial_position: Vector2
var player: CharacterBody2D = null
var current_dive_speed: float = 0.0

# Cooldowns activos por estado (manejados por State)
var active_cooldowns: Array[State] = []

func _ready() -> void:
	add_to_group("buho")
	initial_position = global_position
	
	# Conectar señales del área de detección
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)
	
	# Sprite inicial mirando a la izquierda
	anim.flip_h = false

func _process(delta: float) -> void:
	# Actualizar cooldowns de todos los estados activos
	for state in active_cooldowns:
		state.update_cooldown(delta)
	
	# Limpiar cooldowns terminados
	active_cooldowns = active_cooldowns.filter(func(s): return s.is_on_cooldown())

# ==============================================================================
# SISTEMA DE COOLDOWN POR ESTADO
# ==============================================================================
func register_state_cooldown(state: State):
	"""Registra un estado con cooldown activo"""
	if state not in active_cooldowns:
		active_cooldowns.append(state)

# ==============================================================================
# DETECCIÓN DEL JUGADOR
# ==============================================================================
func _on_detection_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body == player:
		player = null

func can_see_player() -> bool:
	"""Verifica si el jugador está en el cono frontal de visión"""
	if not player:
		return false
	
	var direction_to_player = (player.global_position - global_position).normalized()
	var facing_direction = Vector2.LEFT if not anim.flip_h else Vector2.RIGHT
	
	var angle = facing_direction.angle_to(direction_to_player)
	var angle_degrees = abs(rad_to_deg(angle))
	
	return angle_degrees <= VISION_CONE_ANGLE / 2.0

func flip_to_player():
	"""Voltea el sprite hacia el jugador"""
	if player:
		anim.flip_h = player.global_position.x > global_position.x

# ==============================================================================
# SISTEMA DE VIDA
# ==============================================================================
func hazard():
	LIFE -= 1
	if LIFE <= 0:
		_trigger_death()

func vida():
	LIFE += 1
	if LIFE >= 3:
		_trigger_death()

func _trigger_death():
	queue_free()
