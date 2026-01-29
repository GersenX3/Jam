extends State
class_name RabbitStalkingState

func enter():
	super.enter()
	
	# Animación de acecho
	if character.anim:
		character.anim.play("walk")  # O "stalking" si tienes animación específica

func exit():
	super.exit()

func process_physics(delta: float) -> State:
	# Si el jugador sale del rango -> Idle
	if not character.is_player_in_range:
		return state_machine.get_node("Idle")
	
	# Si el jugador nos mira -> Hidden (¡nos congelamos!)
	if character.is_player_looking_at_me():
		return state_machine.get_node("Hidden")
	
	# Perseguir al jugador sigilosamente
	_stalk_player()
	
	return null

func _stalk_player():
	"""
	Movimiento de acecho hacia el jugador
	"""
	if not character.player:
		return
	
	# Obtener dirección hacia el jugador
	var direction = character.get_direction_to_player()
	
	# Mover hacia el jugador
	character.velocity.x = direction.x * character.stalking_speed
	
	# Voltear sprite según dirección
	if character.anim:
		character.anim.flip_h = direction.x < 0
