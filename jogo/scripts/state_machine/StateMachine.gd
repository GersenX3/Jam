# -----------------------------------------------------------------------------
# StateMachine.gd
# -----------------------------------------------------------------------------
# Este nodo gestionará el estado actual y las transiciones.
# Será un hijo de nuestro PlatformerController2DGerson.
# -----------------------------------------------------------------------------
class_name StateMachine
extends Node

# El estado inicial de la máquina. Lo asignaremos desde el inspector.
@export var initial_state: State
# ⭐ COOLDOWN SYSTEM
@export_group("Cooldown Settings")
@export var use_cooldown: bool = false  # Activar sistema de cooldown
@export var cooldown_duration: float = 0.3  # 0.3 segundos de cooldown

var current_cooldown: float = 0.0  # Tiempo restante de cooldown
# El estado en el que nos encontramos actualmente.
var current_state: State

func _ready():
	# Al iniciar, asignamos las referencias a todos los estados hijos.
	for child in get_children():
		if child is State:
			child.character = get_parent()
			child.state_machine = self
			
	# Empezamos en el estado inicial.
	if initial_state:
		current_state = initial_state
		current_state.enter()

func _process(delta):
	if current_state:
		# Pasamos la lógica de _process al estado actual.
		var next_state = current_state.process_frame(delta)
		if next_state:
			transition_to(next_state)

func _physics_process(delta):
	if current_state:
		# Pasamos la lógica de _physics_process al estado actual.
		var next_state = current_state.process_physics(delta)
		if next_state:
			transition_to(next_state)

func _input(event: InputEvent):
	if current_state:
		# Pasamos la lógica de _input al estado actual.
		var next_state = current_state.process_input(event)
		if next_state:
			transition_to(next_state)

# La función mágica que cambia de un estado a otro.
func transition_to(new_state: State):
	if current_state and new_state:
		# Salimos del estado actual.
		current_state.exit()
		# Entramos en el nuevo estado.
		current_state = new_state
		current_state.enter()

# ==============================================================================
# SISTEMA DE COOLDOWN
# ==============================================================================

func update_cooldown(delta: float):
	"""
	Actualiza el cooldown. Llamado automáticamente por el player cada frame.
	"""
	if current_cooldown > 0:
		current_cooldown -= delta
		if current_cooldown < 0:
			current_cooldown = 0.0

func get_cooldown_remaining() -> float:
	"""
	Retorna el tiempo restante de cooldown
	"""
	return current_cooldown

func is_on_cooldown() -> bool:
	"""
	Verifica si el estado está en cooldown
	"""
	return current_cooldown > 0.0

func can_enter() -> bool:
	"""
	Verifica si se puede entrar al estado (sin cooldown activo)
	"""
	if use_cooldown:
		return not is_on_cooldown()
	return true

func start_cooldown():
	"""
	Inicia el cooldown al salir del estado
	"""
	if use_cooldown:
		current_cooldown = cooldown_duration
		print("CottonWall: Cooldown iniciado (", cooldown_duration, "s)")
