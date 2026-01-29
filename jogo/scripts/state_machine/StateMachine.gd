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

# ⭐ DEBUG SYSTEM
@export_group("Debug Settings")
@export var debug: bool = false  # Activar label de debug
var debug_label: Label = null  # Referencia al label creado

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
	
	# Crear label de debug si está activado
	if debug:
		_create_debug_label()
	
	# Empezamos en el estado inicial.
	if initial_state:
		current_state = initial_state
		current_state.enter()
		_update_debug_label()

func _process(delta):
	if current_state:
		# Pasamos la lógica de _process al estado actual.
		var next_state = current_state.process_frame(delta)
		if next_state:
			transition_to(next_state)
	
	# Actualizar label de debug cada frame
	if debug:
		_update_debug_label()

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
		# Actualizar label al cambiar de estado
		_update_debug_label()

# ==============================================================================
# SISTEMA DE DEBUG
# ==============================================================================
func _create_debug_label():
	"""
	Crea un Label dinámico en el padre (personaje) para mostrar el estado actual
	"""
	var parent = get_parent()
	if not parent:
		push_warning("StateMachine: No se pudo crear debug label, no hay padre")
		return
	
	# Crear el Label
	debug_label = Label.new()
	debug_label.name = "StateDebugLabel"
	
	# Configuración visual básica
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.add_theme_color_override("font_color", Color.YELLOW)
	debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
	debug_label.add_theme_constant_override("outline_size", 2)
	
	# Posición relativa al personaje (arriba)
	debug_label.position = Vector2(-30, -40)
	debug_label.z_index = 100  # Siempre visible sobre otros elementos
	
	# Añadir al padre
	parent.add_child.call_deferred(debug_label)
	
	print("StateMachine: Debug label creado")

func _update_debug_label():
	"""
	Actualiza el texto del label con el estado actual y cooldown si aplica
	"""
	if not debug or not debug_label:
		return
	
	var state_name = current_state.name if current_state else "NONE"
	var text = "State: " + state_name
	
	# Añadir info de cooldown si está activo
	if use_cooldown and current_cooldown > 0:
		text += "\nCD: %.2fs" % current_cooldown
	
	debug_label.text = text

func _exit_tree():
	"""
	Limpieza: eliminar el label cuando se destruye la state machine
	"""
	if debug_label and is_instance_valid(debug_label):
		debug_label.queue_free()

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
