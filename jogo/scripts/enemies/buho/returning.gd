# ReturningState.gd
extends State

var return_progress: float = 0.0

func enter():
	super.enter()
	character.anim.play("return")
	return_progress = 0.0
	print("Búho: Regresando a posición inicial")

func process_physics(delta: float) -> State:
	# Interpolación suave hacia la posición inicial
	var distance = character.global_position.distance_to(character.initial_position)
	
	if distance < 5.0:
		# Llegó a su posición
		character.global_position = character.initial_position
		return state_machine.get_node_or_null("Perched")
	
	# Movimiento con interpolación suave
	return_progress += delta * 2.0  # Velocidad de interpolación
	var t = clamp(return_progress, 0.0, 1.0)
	
	# Ease out para suavidad
	t = 1.0 - pow(1.0 - t, 3.0)
	
	# Mover hacia la posición inicial
	var direction = (character.initial_position - character.global_position).normalized()
	character.velocity = direction * character.RETURN_SPEED
	
	character.move_and_slide()
	
	return null

func exit():
	super.exit()
	character.velocity = Vector2.ZERO
