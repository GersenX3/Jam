extends State
class_name RabbitHiddenState

func enter():
	super.enter()
	
	# Detener movimiento
	character.velocity = Vector2.ZERO
	
	# Animación de esconderse o quedarse quieto
	if character.anim:
		character.anim.play("hidden")  # O "idle" si no tienes animación específica

func exit():
	super.exit()

func process_physics(delta: float) -> State:
	# Asegurarse de que no se mueva
	character.velocity = Vector2.ZERO
	
	# Si el jugador sale del rango -> Idle
	if not character.is_player_in_range:
		return state_machine.get_node("Idle")
	
	# Si el jugador deja de mirarnos -> Stalking (¡momento de acercarse!)
	if not character.is_player_looking_at_me():
		return state_machine.get_node("Stalking")
	
	# Seguir escondido mientras nos miren
	return null
