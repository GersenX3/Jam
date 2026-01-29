# ==============================================================================
# gato_idle_state.gd
# ==============================================================================
# Estado Idle: El gato patrulla aleatoriamente de izquierda a derecha
# Transición: Cuando detecta al jugador → ChasingState
# ==============================================================================
extends State

@export var patrol_speed: float = 100.0
@export var idle_time_min: float = 1.0
@export var idle_time_max: float = 3.0
@export var move_time_min: float = 2.0
@export var move_time_max: float = 4.0

var idle_timer: float = 0.0
var move_timer: float = 0.0
var is_moving: bool = false
var move_direction: int = 1

func enter() -> void:
	super.enter()
	print("Gato: Estado IDLE")
	if character.anim:
		character.anim.play("idle")
	_start_idle()

func exit() -> void:
	character.velocity.x = 0

func process_physics(delta: float) -> State:
	# Verificar si el jugador está en rango → Cambiar a Chase
	if character.player != null:
		return get_node("../Chasing")
	
	# Lógica de patrullaje
	if is_moving:
		# Moverse en la dirección actual
		character.velocity.x = move_direction * patrol_speed
		character.flip_sprite(move_direction)
		character.anim.play("run")
		
		move_timer -= delta
		if move_timer <= 0:
			_start_idle()
	else:
		# Estar quieto
		character.velocity.x = 0
		character.anim.play("idle")
		
		idle_timer -= delta
		if idle_timer <= 0:
			_start_moving()
	
	return null

func _start_idle() -> void:
	"""Inicia un periodo de estar quieto"""
	is_moving = false
	idle_timer = randf_range(idle_time_min, idle_time_max)

func _start_moving() -> void:
	"""Inicia un periodo de movimiento aleatorio"""
	is_moving = true
	move_timer = randf_range(move_time_min, move_time_max)
	# Cambiar dirección aleatoriamente
	move_direction = 1 if randf() > 0.5 else -1
