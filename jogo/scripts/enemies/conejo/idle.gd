extends State
class_name RabbitIdleState

# ============================================================================
# VARIABLES DE PATRULLAJE
# ============================================================================
var patrol_direction: int = 1  # 1 = derecha, -1 = izquierda
var patrol_timer: float = 0.0
var time_to_change_direction: float = 0.0

func enter():
	super.enter()
	
	if character.anim:
		character.anim.play("idle")  # O "walk" si tienes animación de caminar
	
	# Configurar tiempo aleatorio para cambiar de dirección (1-3 segundos)
	_set_random_direction_change()

func exit():
	super.exit()

func process_physics(delta: float) -> State:
	# Verificar si el jugador está en rango
	if not character.is_player_in_range:
		# Si el jugador salió del rango, nos quedamos en Idle
		_patrol(delta)
		return null
	
	# Si el jugador está en rango Y no nos está mirando -> Stalking
	if character.is_player_in_range and not character.is_player_looking_at_me():
		return state_machine.get_node("Stalking")
	
	# Si está en rango pero nos mira -> Hidden
	if character.is_player_in_range and character.is_player_looking_at_me():
		return state_machine.get_node("Hidden")
	
	# Patrullar mientras esperamos
	_patrol(delta)
	
	return null

func _patrol(delta: float):
	"""
	Movimiento aleatorio del conejo
	"""
	patrol_timer += delta
	
	# Cambiar de dirección cuando se cumpla el tiempo
	if patrol_timer >= time_to_change_direction:
		patrol_timer = 0.0
		_set_random_direction_change()
		patrol_direction *= -1  # Cambiar dirección
	
	# Mover al conejo
	character.velocity.x = patrol_direction * character.idle_speed
	
	# Voltear sprite según dirección
	if character.anim:
		character.anim.flip_h = patrol_direction < 0

func _set_random_direction_change():
	"""
	Establece un tiempo aleatorio para el próximo cambio de dirección
	"""
	time_to_change_direction = randf_range(1.5, 3.5)
