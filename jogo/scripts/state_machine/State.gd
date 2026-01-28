# -----------------------------------------------------------------------------
# State.gd
# -----------------------------------------------------------------------------
# Clase base para todos los estados del jugador.
# Cada estado (Idle, Move, Jump, etc.) heredará de esta clase.
# Ahora incluye sistema de cooldown configurable.
# -----------------------------------------------------------------------------
class_name State
extends Node

# Referencia al controlador del personaje para poder acceder a sus variables (como `velocity`) y nodos (como `PlayerSprite`).
# La asignaremos automáticamente.
@export var character: CharacterBody2D
@export var state_machine: StateMachine

# ==============================================================================
# SISTEMA DE COOLDOWN
# ==============================================================================
@export_group("Cooldown Settings")
@export var use_cooldown: bool = false  # Activar/desactivar cooldown para este estado
@export var cooldown_duration: float = 0.5  # Duración del cooldown en segundos
@export var cooldown_affects_entry: bool = true  # Si true, no se puede entrar al estado durante cooldown

# Cooldown actual (manejado por el character)
var current_cooldown: float = 0.0

# ==============================================================================
# MÉTODOS BASE DEL ESTADO
# ==============================================================================

func enter():
	"""
	Se ejecuta UNA VEZ al entrar en este estado.
	Perfecto para inicializar cosas o reproducir una animación.
	"""
	# Activar el cooldown al entrar si está configurado
	if use_cooldown:
		current_cooldown = cooldown_duration
		start_cooldown()

func exit():
	"""
	Se ejecuta UNA VEZ al salir de este estado.
	Ideal para limpiar timers o resetear variables.
	"""
	pass

func process_input(_event: InputEvent) -> State:
	"""
	Maneja el input del usuario. Puede devolver un nuevo estado para transicionar.
	Ej: Si estamos en Idle y el jugador presiona 'jump', devolvemos el estado de Salto.
	"""
	return null

func process_physics(_delta: float) -> State:
	"""
	Maneja la lógica de físicas. Se ejecuta en cada frame de _physics_process.
	Puede devolver un nuevo estado para transicionar.
	Ej: Si estamos en el aire (FallState) y tocamos el suelo, devolvemos el estado Idle.
	"""
	return null

func process_frame(_delta: float) -> State:
	"""
	Maneja la lógica normal. Se ejecuta en cada frame de _process.
	Útil para lógica de animación o timers que no son de física.
	"""
	return null

# ==============================================================================
# SISTEMA DE COOLDOWN
# ==============================================================================

func start_cooldown():
	print("EMPEZO COOLDOWN")
	"""
	Inicia el cooldown del estado.
	Llamado automáticamente al entrar si use_cooldown está activo.
	"""
	current_cooldown = cooldown_duration
	if character:
		character.register_state_cooldown(self)

func is_on_cooldown() -> bool:
	"""
	Verifica si el estado está actualmente en cooldown.
	"""
	return current_cooldown > 0.0

func get_cooldown_remaining() -> float:
	"""
	Retorna el tiempo restante del cooldown.
	"""
	return max(0.0, current_cooldown)

func get_cooldown_percent() -> float:
	"""
	Retorna el porcentaje de cooldown restante (0.0 - 1.0).
	Útil para UI de cooldown.
	"""
	if cooldown_duration <= 0:
		return 0.0
	return clamp(current_cooldown / cooldown_duration, 0.0, 1.0)

func can_enter() -> bool:
	"""
	Verifica si se puede entrar a este estado.
	Toma en cuenta el cooldown si está configurado.
	"""
	if use_cooldown and cooldown_affects_entry:
		print("PUEDE ENTRAR ", not is_on_cooldown())
		return not is_on_cooldown()
	return true

func update_cooldown(delta: float):
	#aprint(current_cooldown)
	"""
	Actualiza el cooldown. 
	Llamado automáticamente por el character en _process.
	"""
	if current_cooldown > 0.0:
		current_cooldown -= delta
		if current_cooldown <= 0.0:
			current_cooldown = 0.0
			_on_cooldown_finished()

func _on_cooldown_finished():
	print("Termino cooldown")
	"""
	Callback cuando el cooldown termina.
	Override en estados hijos si necesitas hacer algo específico.
	"""
	pass
